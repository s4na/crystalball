# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Manages map generation strategies
    class StrategiesCollection
      include Enumerable

      def initialize(strategies = [])
        @strategies = strategies
      end

      # Run before hook action for example or example group
      #
      # @param example [RSpec::Core::Example]
      # @return [void]
      def run_before(example)
        _strategies.reverse_each { |strategy| strategy.run_before(example) }
      end

      # Run after hook action for example or example group and update example group map
      #
      # @param example_group_map [ExampleGroupMap]
      # @param example [RSpec::Core::Example]
      # @return [ExampleGroupMap]
      def run_after(example_group_map, example)
        _strategies.reverse_each do |strategy|
          strategy.run_after(example_group_map, example)
        end

        example_group_map
      end

      def method_missing(method_name, *args, &block)
        _strategies.public_send(method_name, *args, &block) || super
      end

      def respond_to_missing?(method_name, *_args)
        _strategies.respond_to?(method_name, false) || super
      end

      private

      def _strategies
        @strategies
      end
    end
  end
end
