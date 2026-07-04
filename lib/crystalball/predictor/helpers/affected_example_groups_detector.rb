# frozen_string_literal: true

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
          map.example_groups.map do |uid, example_group_map|
            uid if files.any? { |file| affected_by_file?(file, example_group_map) }
          end.compact
        end

        private

        def affected_by_file?(file, example_group_map)
          example_group_map.any? do |entry|
            case entry
            when String
              entry == relative_path(file)
            when Hash
              affected_by_line_map?(file, entry)
            end
          end
        end

        def relative_path(file)
          file.respond_to?(:relative_path) ? file.relative_path : file
        end

        def affected_by_line_map?(file, line_map)
          executed_lines = line_map[relative_path(file)]
          return false unless executed_lines

          changed_lines = file.respond_to?(:changed_lines) ? file.changed_lines : []
          return true if changed_lines.empty?
          return true if file.respond_to?(:inserted_lines) && file.inserted_lines.any?

          (changed_lines & executed_lines).any?
        end
      end
    end
  end
end
