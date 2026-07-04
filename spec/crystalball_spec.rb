# frozen_string_literal: true

require "spec_helper"

describe Crystalball do
  describe ".foresee" do
    let(:map) { instance_double(Crystalball::ExecutionMap, commit: commit) }
    let(:repo) { instance_double(Crystalball::GitRepo, diff: nil) }
    let(:predictor) { instance_double(Crystalball::Predictor, prediction: double) }
    let(:commit) { double }

    before do
      allow(Crystalball::MapStorage::YAMLStorage).to receive(:load).with(Pathname("crystalball_data.yml")).and_return(map)
      allow(Crystalball::GitRepo).to receive(:open).with(Pathname(".")).and_return(repo)
    end

    it "initializes predictor and returns example_groups" do
      allow(Crystalball::Predictor).to receive(:new).with(map, repo, from: commit).and_return(predictor)
      compact_prediction = double
      allow(predictor).to receive(:prediction).and_return(double(compact: compact_prediction))

      expect(described_class.foresee).to eq compact_prediction
    end

    context "when git repository cannot be opened" do
      before do
        allow(Crystalball::GitRepo).to receive(:open).with(Pathname(".")).and_return(nil)
      end

      it "raises a clear git repository error" do
        expect { described_class.foresee }
          .to raise_error(Crystalball::GitRepo::UnavailableError, Crystalball::GitRepo::UNAVAILABLE_MESSAGE)
      end
    end
  end
end
