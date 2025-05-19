# frozen_string_literal: true

require "spec_helper"

describe Crystalball::MapGenerator::OneshotCoverageStrategy do
  subject(:generator) { described_class.new }

  include_examples "base strategy"

  describe "#after_register" do
    let(:cov_running) { false }

    before do
      allow(Coverage).to receive(:running?).and_return(cov_running)
    end

    context "when Coverage is already running" do
      let(:cov_running) { true }

      it "raises error" do
        expect { generator.after_register }.to raise_error("Coverage must not be started for oneshot_line strategy")
      end
    end

    context "when Coverage is not running" do
      it "does nothing" do
        expect(Coverage).not_to receive(:start)

        generator.after_register
      end
    end
  end

  describe "#call" do
    let(:example_group_map) { [] }
    let(:example) { instance_double(RSpec::Core::Example, id: "example_group.example_id") }

    before do
      allow(Coverage).to receive(:start).with(oneshot_lines: true)
      allow(Coverage).to receive(:result).and_return({ "#{Dir.pwd}/file_1" => [1, 2], "#{Dir.pwd}/file_2" => [1, 2] })
    end

    it "pushes used files detected by detector to example group map" do
      expect do
        generator.call(example_group_map, example) do
          # empty block called by generator implementation
        end
      end.to change { example_group_map }.to %w[file_1 file_2]
    end

    it "yields example_group_map to a block" do
      expect do |b|
        generator.call(example_group_map, example, &b)
      end.to yield_with_args(example_group_map, example)
    end
  end
end
