# frozen_string_literal: true

require "coverage"
require "crystalball/map_generator/base_strategy"
require "crystalball/map_generator/coverage_strategy/execution_detector"

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class CoverageStrategy
      include BaseStrategy

      attr_reader :execution_detector

      def initialize(execution_detector: ExecutionDetector.new)
        @execution_detector = execution_detector
        @before_coverage = nil
      end

      def after_register
        return if Coverage.running?

        log_debug("Starting coverage capture")
        Coverage.start(lines: true)
      end

      def run_before(example)
        log_debug("Fetching current coverage state before execution of example id: #{example.id}")
        @before_coverage = Coverage.peek_result
      end

      def run_after(example_map, example)
        unless before_coverage
          log(:warn, "[CoverageStrategy] Skipping coverage detection for #{example.id}: " \
            "before_coverage is nil (nested context hooks may have cleared it)")
          return
        end

        log_debug("Recording mappings for example id: #{example.id}")
        mappings = execution_detector.detect(before_coverage, Coverage.peek_result)
        log_debug("#{example.id} recorded #{mappings.size} files")
        example_map.push(*mappings)
      ensure
        @before_coverage = nil
      end

      private

      attr_reader :before_coverage
    end
  end
end
