# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "crystalball/version"

Gem::Specification.new do |spec|
  spec.name          = "crystalball-gitlab"
  spec.version       = Crystalball::VERSION
  spec.authors       = ["Developer Experience Team"]
  spec.email         = ["developer-experience@gitlab.com"]

  spec.summary       = "A library for RSpec regression test selection"
  spec.description   = "Provides simple way to integrate regression test selection approach to your RSpec test suite"

  homepage           = "https://gitlab.com/acunskis/crystalball"
  spec.homepage      = homepage

  spec.metadata = {
    "bug_tracker_uri" => "#{homepage}/-/issues",
    "changelog_uri" => "#{homepage}/-/releases",
    "documentation_uri" => "#{homepage}/-/blob/main/docs/index.md",
    "source_code_uri" => "#{homepage}/-/tree/main",
    "wiki_uri" => "#{homepage}/-/wikis/home",
    "rubygems_mfa_required" => "false"
  }

  spec.required_ruby_version = "> 3.1.0"

  spec.files         = Dir["README.md", "LICENSE", "lib/**/*.rb", "bin/crystalball"]
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.executables   = [File.basename("bin/crystalball")]

  spec.add_dependency "git", "~> 3.0.0"

  spec.add_development_dependency "actionview", "~> 8.0.2"
  spec.add_development_dependency "activerecord", "~> 8.0.2"
  spec.add_development_dependency "factory_bot", "~> 6.5.1"
  spec.add_development_dependency "gitlab-styles", "~> 13.1.0"
  spec.add_development_dependency "i18n", "~> 1.14.7"
  spec.add_development_dependency "parser", "~> 3.3.8.0"
  spec.add_development_dependency "pry", "~> 0.15.2"
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rspec", "~> 3.13.0"
  spec.add_development_dependency "semver2", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.22.0"
  spec.add_development_dependency "sqlite3", "~> 2.6.0"
  spec.add_development_dependency "yard", "~> 0.9.37"
end
