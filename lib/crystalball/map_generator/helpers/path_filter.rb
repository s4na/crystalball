# frozen_string_literal: true

module Crystalball
  class MapGenerator
    module Helpers
      # Helper module to filter file paths
      module PathFilter
        attr_reader :root_path, :exclude_prefixes

        # @param [String] root_path - absolute path to root folder of repository
        # @param [Array] exclude_prefixes - list of prefixes to filter out from paths
        def initialize(root_path = Dir.pwd, exclude_prefixes: [])
          @root_path = root_path
          @exclude_prefixes = exclude_prefixes
        end

        # @param [Array<String>] paths
        # @return relative paths inside root_path only
        def filter(paths)
          paths.filter_map do |path|
            next unless path.start_with?(root_path)

            valid_path(path)
          end
        end

        private

        # Return relative path if it is a valid path
        #
        # @param path [String]
        # @return [<String, nil>]
        def valid_path(path)
          return unless path.start_with?(root_path)

          relative_path = path.sub("#{root_path}/", "")
          return if exclude_prefixes&.any? { |prefix| relative_path.start_with?(prefix) }

          relative_path
        end
      end
    end
  end
end
