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

      def run_before(_example)
        log_debug("Starting oneshot_line coverage capture")
        return Coverage.start(oneshot_lines: true) unless Coverage.running?

        log(:warn, "Coverage has been already started, restarting coverage for oneshot_lines!", prefix_class_name: true)
        Coverage.result(stop: true, clear: true)
        Coverage.start(oneshot_lines: true)
      end

      # Adds to the example_map's used files the ones the ones in which
      # the coverage has changed after the tests runs.
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      def run_after(example_map, example)
        paths = filter(Coverage.result(stop: true, clear: true).keys)
        log_debug("#{example.id} recorded #{paths.size} files")
        example_map.push(*paths)
      end
    end
  end
end
