# frozen_string_literal: true

require "coverage"
require "crystalball/map_generator/base_strategy"

require_relative "helpers/path_filter"

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class OneshotCoverageStrategy
      include BaseStrategy
      include Logging
      include Helpers::PathFilter

      def after_register
        raise "Coverage must not be started for oneshot_line strategy" if Coverage.running?
      end

      # Adds to the example_map's used files the ones the ones in which
      # the coverage has changed after the tests runs.
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def call(example_map, example)
        start_coverage
        yield example_map, example
        paths = Coverage.result.keys
        example_map.push(*filter(paths))
      end

      # Start coverage or restart it if it was already started
      #
      # @return [void] <description>
      def start_coverage
        Coverage.start(oneshot_lines: true) unless Coverage.running?

        log(:warn, "[Crystalball] Coverage has been already started, restarting coverage for oneshot_lines!")
        Coverage.result(stop: true, clear: true)
        Coverage.start(oneshot_lines: true)
      end
    end
  end
end
