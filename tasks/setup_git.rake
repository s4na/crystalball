# frozen_string_literal: true

require "semver"

module Crystalball
  # Set up Git configurations for CI operations
  #
  class SetupGitTask
    include Rake::DSL

    def initialize
      add_git_setup_task
    end

    # Add version bump task
    #
    def add_git_setup_task
      desc("Setup git for ci operations")
      task(:setup_git) do
        raise "This task must be executed inside GitLab CI" unless ENV["CI"]
        raise "'VERSION_UPDATE_TOKEN' variable must be set to token with write repository scope" unless update_token

        setup_git
      end
    end

    private

    # Update token with write repository scope
    #
    # @return [String]
    def update_token
      @update_token ||= ENV["VERSION_UPDATE_TOKEN"]
    end

    # Current branch name
    #
    # @return [String]
    def branch
      @branch ||= ENV["CI_COMMIT_REF_NAME"]
    end

    # Setup global git user and origin url
    #
    # @return [void]
    def setup_git
      log "Setup global user and origin"
      sh "git remote set-url origin 'https://gitlab-ci-token:#{update_token}@#{ENV['CI_SERVER_HOST']}/#{ENV['CI_PROJECT_PATH']}.git'"
      sh "git checkout -b #{branch} origin/#{branch}"
      sh "git config --global user.name 'CI'"
      sh "git config --global user.email 'developer-experience@gitlab.com'"
    end

    # Print colorized log message
    #
    # @param msg [String]
    # @return [void]
    def log(msg)
      puts "\033[1;34m#{msg}\033[0m"
    end
  end
end
