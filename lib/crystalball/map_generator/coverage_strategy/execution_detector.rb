# frozen_string_literal: true

require_relative "../helpers/path_filter"

module Crystalball
  class MapGenerator
    class CoverageStrategy
      # Class for detecting code execution path based on coverage information diff
      class ExecutionDetector
        include ::Crystalball::MapGenerator::Helpers::PathFilter

        # Detects files affected during example execution. Transforms absolute paths to relative.
        # Exclude paths outside of repository
        #
        # @param[Array<String>] list of files affected before example execution
        # @param[Array<String>] list of files affected after example execution
        # @return [Array<String>]
        def detect(before, after)
          # `before` can be nil when specs run nested example groups inside a
          # before(:context) hook, causing inner after(:context) hooks to clear
          # the coverage baseline. CoverageStrategy#run_after logs a warning.
          return [] unless before

          after.filter_map do |file, coverage|
            before_cov = before[file]&.fetch(:lines, [])
            next if before_cov == coverage[:lines]

            path = valid_path(file)
            next unless path

            path
          end
        end
      end
    end
  end
end
