# frozen_string_literal: true

module Crystalball
  # Class to generate execution map during RSpec build execution
  class MapGenerator
    include Logging
    extend Forwardable

    attr_reader :configuration

    delegate %i[map_storage strategies dump_threshold map_class] => :configuration

    class << self
      # Registers Crystalball handlers to generate execution map during specs execution
      #
      # @param [Proc] block to configure MapGenerator and Register strategies
      def start!(&block)
        generator = new(&block)

        ::RSpec.configure do |config|
          config.before(:suite) { generator.start! }
          config.after(:suite) { generator.finalize! }

          if generator.configuration.hook_type == :example
            config.prepend_before(:example) { |e| generator.execute_before(e) }
            config.append_after(:example) { |e| generator.execute_after(e) }
          else
            config.prepend_before(:context) { |e| generator.execute_before(e.class) }
            config.append_after(:context) { |e| generator.execute_after(e.class) }
          end
        end
      end
    end

    def initialize
      @configuration = Configuration.new
      @configuration.commit = repo.gcommit("HEAD") if repo
      yield @configuration if block_given?
    end

    # Registers strategies and prepares metadata for execution map
    def start!
      log_with_prefix("Starting Crystalball execution map builder")

      self.map = nil
      map_storage.clear!
      map_storage.dump(map.metadata.to_h)

      strategies.reverse.each(&:after_start)
      self.started = true
    end

    # Run before step of strategy for given example or example group
    #
    # @param example [RSpec::Core::ExampleGroup, RSpec::Core::Example]
    # @return [void]
    def execute_before(example)
      strategies.run_before(example)
    end

    # Run after step and collect execution map
    #
    # @param example [RSpec::Core::ExampleGroup, RSpec::Core::Example]
    # @return [void]
    def execute_after(example)
      result = strategies.run_after(ExampleGroupMap.new(example), example)
      # do not populate map with nil values
      map << result unless result.used_files.empty?
      check_dump_threshold!
    end

    # Finalizes strategies and saves map
    def finalize!
      return unless started

      log_with_prefix("Finalizing mappings strategies and saving final map")
      strategies.each(&:before_finalize)

      unless map.size.positive?
        log_with_prefix("No files recorded in the execution map")
        return
      end

      example_groups = (configuration.compact_map? ? MapCompactor.compact_map!(map) : map).example_groups
      dump_map_storage(example_groups)
    end

    def map
      @map ||= map_class.new(metadata: {
        commit: configuration.commit&.sha,
        timestamp: configuration.commit&.date&.to_i,
        version: configuration.version
      })
    end

    private

    attr_writer :map
    attr_accessor :started

    def strategy_classes
      @strategy_classes ||= strategies.map { |strategy| strategy.class.name.split("::").last }.join("|")
    end

    def repo
      @repo = GitRepo.open(".") unless defined?(@repo)
      @repo
    end

    def check_dump_threshold!
      return if configuration.compact_map
      return unless dump_threshold.positive? && map.size >= dump_threshold

      log_with_prefix("Intermediate dump threshold (#{dump_threshold}) reached!")
      dump_map_storage(map.example_groups)
    end

    def dump_map_storage(example_groups)
      log_with_prefix("Dumping #{example_groups.size} examples to #{configuration.map_storage_path} file")
      map_storage.dump(example_groups)
      map.clear!
    end

    # Log message with prefix containing strategy names
    #
    # @param message [String]
    # @return [void]
    def log_with_prefix(message)
      log(:info, "[#{strategy_classes}]: #{message}")
    end
  end
end
