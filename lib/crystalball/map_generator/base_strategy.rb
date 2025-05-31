# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Map generator strategy interface
    module BaseStrategy
      include Logging

      def after_register; end

      def after_start; end

      def before_finalize; end

      # Run before the execution of the example or example group
      #
      # @param _example [RSpec::Core::ExampleGroup, RSpec::Core::Example]
      # @return [void]
      def run_before(_example)
        raise NotImplementedError
      end

      # Run after the execution of the example or example group
      #
      # @param _example_map [Crystalball::ExampleGroupMap]
      # @param _example [RSpec::Core::ExampleGroup, RSpec::Core::Example]
      # @return [Crystalball::ExampleGroupMap]
      def run_after(_example_map, _example)
        raise NotImplementedError
      end

      private

      # Print debug log messages with included strategy class name prefix
      #
      # @param msg [String]
      # @return [void]
      def log_debug(msg)
        log(:debug, msg, prefix_class_name: true)
      end
    end
  end
end
