# frozen_string_literal: true

require "spec_helper"

describe Crystalball::MapGenerator::BaseStrategy do
  subject(:base_strategy) do
    Object.new.tap do |o|
      o.extend described_class
    end
  end

  it_behaves_like "base strategy"

  describe "#run_before" do
    specify do
      expect do
        base_strategy.run_before(1)
      end.to raise_error NotImplementedError
    end
  end

  describe "#run_after" do
    specify do
      expect do
        base_strategy.run_after(1, 2)
      end.to raise_error NotImplementedError
    end
  end
end
