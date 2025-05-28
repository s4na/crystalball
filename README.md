# Crystalball

![Build Status](https://gitlab.com/gitlab-org/ruby/gems/crystalball/badges/main/pipeline.svg)
![Test Coverage](https://gitlab.com/gitlab-org/ruby/gems/crystalball/badges/main/coverage.svg?job=rspec)

Crystalball is a Ruby library which implements [Regression Test Selection mechanism](https://tenderlovemaking.com/2015/02/13/predicting-test-failues.html) originally published by Aaron Patterson.
Its main purpose is to select a minimal subset of your test suite which should be run to ensure your changes didn't break anything.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'crystalball'
end
```

And then execute:

```console
  bundle install
```

Or install it yourself as:

```console
  gem install crystalball
```

## Usage

Please see our [official documentation](https://gitlab.com/gitlab-org/ruby/gems/crystalball/-/blob/main/docs/index.md).

### Versioning

We use [semantic versioning](https://semver.org/) for our [releases](https://gitlab.com/gitlab-org/ruby/gems/crystalball/-/releases).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Release

In order to release new version, manual pipeline should be triggered via Gitlab UI and version component input should be set according to [semver versioning](#versioning) strategy. Pipeline will then automatically bump version, push updated files and release tag and build and push gem to <rubygems.org>.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/toptal/crystalball>.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Crystalball is released under the [MIT License](https://opensource.org/licenses/MIT).
