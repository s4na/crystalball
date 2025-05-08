# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task default: :spec

load "tasks/setup_git.rake"
Crystalball::SetupGitTask.new

load "tasks/version.rake"
Crystalball::VersionTask.new
