# frozen_string_literal: true

require "set"

module Crystalball
  class Predictor
    module Helpers
      # Helper module to fetch example groups affected by given list of changed files
      module AffectedExampleGroupsDetector
        # Fetch examples affected by given list of files
        # @param [Array<String>] files - list of files
        # @param [Crystalball::ExecutionMap] map - execution map with examples
        # @return [Array<String>] list of affected examples
        def detect_examples(files, map)
          changed_files = files.to_set

          map.example_groups.each_with_object([]) do |(uid, example_group_map), affected_examples|
            affected_examples << uid if example_group_map.any? { |file| changed_files.include?(file) }
          end
        end
      end
    end
  end
end
