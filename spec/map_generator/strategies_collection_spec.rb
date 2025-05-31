# frozen_string_literal: true

require "spec_helper"

describe Crystalball::MapGenerator::StrategiesCollection do
  subject(:strategies) { described_class.new }

  let(:strategy) do
    Struct.new(:name) do
      def run_before(example)
        example.id
      end

      def run_after(group_map, _example)
        group_map.push(name)
      end
    end
  end

  let(:strategy_1) { strategy.new("strategy_1") }
  let(:strategy_2) { strategy.new("strategy_2") }
  let(:rspec_example) { instance_double(RSpec::Core::Example, id: "test-id:[1]") }

  describe "#method_missing" do
    it "delegates to strategies array" do
      expect(strategies).to respond_to :empty?
      expect(strategies).to be_empty
    end
  end

  describe "#run_before" do
    before do
      strategies.push(strategy_1, strategy_2)
    end

    it "executes all strategies run_before methods" do
      strategies.run_before(rspec_example)

      expect(rspec_example).to have_received(:id).twice
    end
  end

  describe "#run_after" do
    let(:group_map) { [] }

    before do
      strategies.push(strategy_1, strategy_2)
    end

    it "executes all strategies run_after methods" do
      expect { strategies.run_after(group_map, rspec_example) }.to change { group_map }.to(%w[strategy_2 strategy_1])
    end
  end
end
