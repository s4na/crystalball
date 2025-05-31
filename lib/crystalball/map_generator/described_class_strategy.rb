# frozen_string_literal: true

require "crystalball/map_generator/base_strategy"
require "crystalball/map_generator/object_sources_detector"

module Crystalball
  class MapGenerator
    # Map generator strategy to get paths to files contains definition of described_class and its
    # ancestors.
    class DescribedClassStrategy
      include BaseStrategy

      extend Forwardable

      attr_reader :execution_detector

      delegate %i[after_register before_finalize] => :execution_detector

      # @param [#detect] execution_detector - object that, given a list of objects,
      #   returns the paths where the classes or modules of the list are defined
      def initialize(execution_detector: ObjectSourcesDetector.new(root_path: Dir.pwd))
        @execution_detector = execution_detector
      end

      def run_before(_example); end

      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def run_after(example_map, example)
        log_debug("Recording mappings for example id: #{example.id}")
        described_class = example.metadata[:described_class]

        if described_class
          mappings = execution_detector.detect([described_class])
          log_debug("#{example.id} recorded #{mappings.size} files")
          example_map.push(*mappings)
        else
          log_debug("#{example.id} did not record any mappings because it has no described_class")
        end
      end
    end
  end
end
