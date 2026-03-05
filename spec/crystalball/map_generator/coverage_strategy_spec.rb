# frozen_string_literal: true

require "spec_helper"

describe Crystalball::MapGenerator::CoverageStrategy do
  subject(:generator) { described_class.new(execution_detector: execution_detector) }

  let(:execution_detector) { instance_double(Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector) }
  let(:rspec_example) { instance_double(RSpec::Core::Example, id: "test-id:[1]") }

  include_examples "base strategy"

  describe "#after_register" do
    context "when Coverage is already running" do
      it "does nothing" do
        allow(Coverage).to receive(:running?).and_return(true)
        expect(Coverage).not_to receive(:start)

        generator.after_register
      end
    end

    context "when Coverage is not running" do
      it "starts coverage" do
        allow(Coverage).to receive(:running?).and_return(false)
        expect(Coverage).to receive(:start)

        generator.after_register
      end
    end
  end

  describe "#run_after" do
    let(:example_group_map) { [] }

    before do
      before = double
      after = double
      allow(Coverage).to receive(:peek_result).and_return(before, after)
      example_map = [1, 2, 3]
      allow(execution_detector).to receive(:detect).with(before, after).and_return(example_map)
    end

    it "pushes used files detected by detector to example group map" do
      expect do
        generator.run_before(rspec_example)
        generator.run_after(example_group_map, rspec_example)
      end.to change { example_group_map }.to [1, 2, 3]
    end

    context "when before_coverage is nil (no matching run_before)" do
      it "skips detection and leaves example group map unchanged" do
        expect(execution_detector).not_to receive(:detect)

        expect do
          generator.run_after(example_group_map, rspec_example)
        end.not_to change { example_group_map }
      end
    end
  end
end
