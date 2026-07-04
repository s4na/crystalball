# frozen_string_literal: true

require "crystalball/source_diff"

module Crystalball
  # Wrapper class representing Git repository
  class GitRepo
    attr_reader :repo_path

    class UnavailableError < StandardError; end

    UNAVAILABLE_MESSAGE = "Git repository is required to build source diff. " \
                          "Ensure .git is present, git gem is installed, and the repository can be opened."

    class << self
      # @return [Crystalball::GitRepo, nil] instance for given path
      def open(repo_path)
        return unless available?

        path = Pathname(repo_path)
        # A mounted .git directory can still be unusable inside CI containers.
        new(path).tap { |repo| repo.send(:repo) } if exists?(path)
      rescue ArgumentError
        nil
      end

      def available?
        load_git
      end

      # Check if given path contains a .git folder
      def exists?(path)
        path.join(".git").directory?
      end

      private

      def load_git
        require "git"
        require "crystalball/extensions/git"
        true
      rescue LoadError => e
        raise unless e.path == "git"

        false
      end
    end

    # @param [Pathname] repo_path path to repository root folder
    def initialize(repo_path)
      @repo_path = repo_path
    end

    # Proxy all unknown calls to `Git` object
    def method_missing(method, *args, &block)
      repo.public_send(method, *args, &block)
    end

    def respond_to_missing?(method, *)
      repo.respond_to?(method, false)
    end

    # Creates diff
    #
    # @param [String] from starting commit to build a diff. Default: HEAD
    # @param [String] to ending commit to build a diff. Default: nil, will build diff of uncommitted changes
    # @return [SourceDiff]
    def diff(from = "HEAD", to = nil)
      SourceDiff.new(repo.diff(from, to))
    end

    private

    def repo
      raise LoadError, "git gem is required to use #{self.class}" unless self.class.available?

      @repo ||= Git.open(repo_path)
    end
  end
end
