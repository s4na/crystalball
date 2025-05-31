# frozen_string_literal: true

require "rails_helper"

describe Crystalball::Rails::MapGenerator::ActionViewStrategy do
  subject(:strategy) { described_class.new }

  include_examples "base strategy"

  describe "#after_start" do
    subject { strategy.after_start }

    it do
      expect(Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch).to receive(:apply!)
      subject
    end
  end

  describe "#before_finalize" do
    subject { strategy.before_finalize }

    specify do
      expect(Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch).to receive(:revert!)
      subject
    end
  end

  describe "#call" do
    let(:example_group_map) { [] }
    let(:rspec_example) { instance_double(RSpec::Core::Example, id: "test-id:[1]") }

    before do
      allow(strategy).to receive(:filter).with(["view"]).and_return([1, 2, 3])
    end

    it "pushes used files to example group map" do
      strategy.run_before(rspec_example)

      described_class.views.push "view"

      expect { strategy.run_after(example_group_map, rspec_example) }.to change { example_group_map }.to [1, 2, 3]
    end
  end
end
