# frozen_string_literal: true

require "coverage"
require "crystalball/map_generator/base_strategy"

require_relative "helpers/path_filter"

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class OneshotCoverageStrategy
      include BaseStrategy
      include Helpers::PathFilter

      def after_register
        raise "Coverage must not be started for oneshot_line strategy" if Coverage.running?
      end

      # Adds to the example_map's used files the ones the ones in which
      # the coverage has changed after the tests runs.
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def call(example_map, example)
        Coverage.start(oneshot_lines: true)
        yield example_map, example
        paths = Coverage.result.keys
        example_map.push(*filter(paths))
      end
    end
  end
end
