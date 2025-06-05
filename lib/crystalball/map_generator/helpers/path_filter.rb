# frozen_string_literal: true

module Crystalball
  class MapGenerator
    module Helpers
      # Helper module to filter file paths
      module PathFilter
        attr_reader :root_path, :exclude_prefixes

        # @param [String] root_path - absolute path to root folder of repository
        # @param [Array<String, Regexp>] exclude_prefixes - list of prefixes or patterns to filter out from paths
        def initialize(root_path = Dir.pwd, exclude_prefixes: [])
          @root_path = root_path
          @exclude_prefixes = exclude_prefixes
        end

        # @param [Array<String>] paths
        # @return relative paths inside root_path only
        def filter(paths)
          paths.filter_map { |path| valid_path(path) }
        end

        private

        # Return relative path if it is a valid path
        #
        # @param path [String]
        # @return [<String, nil>]
        def valid_path(path)
          return unless path.start_with?(root_path)

          relative_path = path.sub("#{root_path}/", "")
          return if matches_exclude_pattern?(relative_path)

          relative_path
        end

        # Path matches exclude prefix based on string or regex conditions
        #
        # @param path [String]
        # @return [Boolean]
        def matches_exclude_pattern?(path)
          exclude_prefixes&.any? do |prefix|
            next path.match?(prefix) if prefix.instance_of? Regexp

            path.start_with?(prefix)
          end
        end
      end
    end
  end
end
