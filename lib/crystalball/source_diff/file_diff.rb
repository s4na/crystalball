# frozen_string_literal: true

module Crystalball
  class SourceDiff
    # Data object for single file in Git repo diff
    class FileDiff
      # @param [Git::DiffFile] git_diff - raw diff for a single file made by ruby-git gem
      def initialize(git_diff)
        @git_diff = git_diff
      end

      def moved?
        !(git_diff.patch =~ /rename from.*\nrename to/).nil?
      end

      def modified?
        !moved? && git_diff.type == "modified"
      end

      def deleted?
        git_diff.type == "deleted"
      end

      def new?
        git_diff.type == "new"
      end

      # @return relative path to file
      def relative_path
        git_diff.path
      end

      # @return new relative path to file if file was moved
      def new_relative_path
        return relative_path unless moved?

        git_diff.patch.match(/rename from.*\nrename to (.*)/)[1]
      end

      # @return [Array<Integer>] changed line numbers in the new version of the file
      def changed_lines
        return [] unless modified? || new?

        changed_lines = []

        each_changed_line { |new_line, _old_line, _inserted| changed_lines << new_line }

        changed_lines
      end

      # @return [Array<Integer>] newly inserted line numbers in the new version of the file
      def inserted_lines
        return [] unless modified? || new?

        inserted_lines = []

        each_changed_line do |new_line, _old_line, inserted|
          inserted_lines << new_line if inserted
        end

        inserted_lines
      end

      def method_missing(method, *args, &block)
        git_diff.public_send(method, *args, &block) || super
      end

      def respond_to_missing?(method, *)
        git_diff.respond_to?(method, false) || super
      end

      private

      attr_reader :git_diff

      def each_changed_line
        new_line = nil
        old_line = nil
        pending_deletions = 0

        patch.to_s.each_line do |line|
          if (match = line.match(/^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@/))
            old_line = match[1].to_i
            new_line = match[2].to_i
            pending_deletions = 0
            next
          end

          next unless new_line

          case line[0]
          when "+"
            inserted = pending_deletions.zero?
            pending_deletions -= 1 if pending_deletions.positive?
            yield new_line, old_line, inserted
            new_line += 1
          when "-"
            pending_deletions += 1
            old_line += 1
          else
            next if line.start_with?("\\ No newline")

            pending_deletions = 0
            new_line += 1
            old_line += 1
          end
        end
      end
    end
  end
end
