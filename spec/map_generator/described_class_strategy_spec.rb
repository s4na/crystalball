# frozen_string_literal: true

require "spec_helper"

describe Crystalball::MapGenerator::DescribedClassStrategy do
  subject(:strategy) { described_class.new(execution_detector: execution_detector) }

  let(:execution_detector) { instance_double(Crystalball::MapGenerator::ObjectSourcesDetector) }

  it_behaves_like "base strategy"

  describe "#call" do
    let(:example_group_map) { [] }
    let(:objects) { [Dummy] }
    let(:rspec_example) do
      instance_double(RSpec::Core::Example, id: "test-id:[1]", metadata: { described_class: Dummy })
    end

    before do
      stub_const("Dummy", Class.new)
      allow(execution_detector).to receive(:detect).with(objects).and_return([1, 2, 3])
    end

    it "pushes used files detected by detector to example group map" do
      expect do
        strategy.run_after(example_group_map, rspec_example)
      end.to change { example_group_map }.to [1, 2, 3]
    end
  end
end
