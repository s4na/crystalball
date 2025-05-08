# frozen_string_literal: true

require "semver"

module Crystalball
  # Update app version
  #
  class VersionTask
    include Rake::DSL

    VERSION_FILE = "lib/crystalball/version.rb"

    def initialize
      add_version_task
    end

    # Add version bump task
    #
    def add_version_task
      desc("Bump application version [major, minor, patch]")
      task(:bump_version, [:version_component] => :setup_git) do |_task, args|
        raise "This task must be executed inside GitLab CI" unless ENV["CI"]

        new_version = case args[:version_component]
                      when "major"
                        major
                      when "minor"
                        minor
                      when "patch"
                        patch
                      else
                        raise ArgumentError, "You must specify one of these: [major, minor, patch]"
                      end

        version_string = new_version.format("%M.%m.%p").to_s
        update_version(version_string)
        commit_and_push(version_string)
      end
    end

    private

    # Semver of ref from
    #
    # @return [SemVer]
    def version
      @version ||= SemVer.parse(Crystalball::VERSION)
    end

    # Update version file
    #
    # @param [SemVer] new_version
    # @return [void]
    def update_version(new_version)
      log "Update version to #{new_version}"
      u_version = File.read(VERSION_FILE).gsub(Crystalball::VERSION, new_version)
      File.write(VERSION_FILE, u_version)
      puts "Updated version in #{VERSION_FILE}"
      log "Update Gemfile.lock"
      sh "bundle install"
    end

    # Commit updated version file and Gemfile.lock
    #
    # @return [void]
    def commit_and_push(new_version)
      log "Commit updated version"
      sh "git add #{VERSION_FILE} Gemfile.lock"
      sh "git commit -m 'Update version to v#{new_version}'"
      sh "git push origin HEAD:#{ENV['CI_COMMIT_REF_NAME']}"
    end

    # Print colorized log message
    #
    # @param msg [String]
    # @return [void]
    def log(msg)
      puts "\033[1;34m#{msg}\033[0m"
    end

    # Increase patch version
    #
    # @return [SemVer]
    def patch
      version.tap { |ver| ver.patch += 1 }
    end

    # Increase minor version
    #
    # @return [SemVer]
    def minor
      version.tap do |ver|
        ver.minor += 1
        ver.patch = 0
      end
    end

    # Increase major version
    #
    # @return [SemVer]
    def major
      version.tap do |ver|
        ver.major += 1
        ver.minor = 0
        ver.patch = 0
      end
    end
  end
end
