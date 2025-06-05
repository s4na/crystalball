# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Logger" do
  let!(:stdout_logger) { ::Logger.new(output_stream) }
  let!(:file_logger) { ::Logger.new(log_file_output_stream) }

  let(:output_stream) { StringIO.new }
  let(:log_file_output_stream) { StringIO.new }
  let(:log_file) { "tmp/crystalball.log" }
  let(:configured_level) { "warn" }

  around do |example|
    Crystalball.reset_logger
    Crystalball.instance_variable_set(:@config, Crystalball::RSpec::Runner::Configuration.new({
      log_file: log_file,
      log_level: configured_level
    }))

    ClimateControl.modify(CRYSTALBALL_LOG_FILE: log_file, CRYSTALBALL_LOG_LEVEL: configured_level) { example.run }

    Crystalball.reset_logger
    Crystalball.instance_variable_set(:@config, nil)
  end

  before do
    allow(::Logger).to receive(:new).with(STDOUT, progname: "crystalball").and_return(stdout_logger)
    allow(::Logger).to receive(:new).with(Pathname(log_file)).and_return(file_logger)
  end

  it "logs everything to file" do
    log_everything
    result = log_file_output_stream.string.delete("\n")
    expect(result).to match(/.*DEBUG.*INFO.*WARN.*ERROR.*FATAL.*UNKNOWN/)
  end

  it "logs every level equal or above to specified log level" do
    log_everything
    result = output_stream.string.delete("\n")
    expect(result).not_to match(/.*DEBUG.*INFO.*/)
    expect(result).to match(/WARN.*ERROR.*FATAL.*UNKNOWN/)
  end

  private

  def log_everything
    # A log of each type
    Crystalball.log(:debug, "DEBUG")
    Crystalball.log(:info, "INFO")
    Crystalball.log(:warn, "WARN")
    Crystalball.log(:error, "ERROR")
    Crystalball.log(:fatal, "FATAL")
    Crystalball.log(:unknown, "UNKNOWN")
  end
end
