# frozen_string_literal: true

require "open3"
require "rbconfig"
require "spec_helper"

describe Crystalball::Predictor do
  subject(:predictor) { described_class.new(instance_double("Crystalball::ExecutionMap", example_groups: example_groups), repository) }
  let(:example_groups) { {spec_file: %w[file1.rb]} }
  let(:repository) { double("Crystalball::GitRepo", merge_base: double(sha: nil), repo_path: Pathname(".")) }
  let(:map) { instance_double("Crystalball::MapGenerator::ExecutionMap", example_groups: example_groups) }
  let(:example_groups) { {"spec_file" => %w[file1.rb]} }

  describe "#initialize" do
    it "yields block with self" do
      expect do |b|
        described_class.new(double, repository, &b)
      end.to yield_with_args(kind_of(Crystalball::Predictor))
    end
  end

  describe "#prediction" do
    subject { predictor.prediction.to_a }

    let(:source_diff) { instance_double("Crystalball::SourceDiff") }

    before do
      allow(repository).to receive(:diff).and_return(source_diff)
    end

    it { is_expected.to eq([]) }

    context "with predictor" do
      before { predictor.use ->(_source_diff, map) { map.example_groups.keys } }

      context "when file is present" do
        before do
          allow_any_instance_of(Pathname).to receive(:exist?).and_return true
        end

        it { is_expected.to eq(["spec_file"]) }
      end

      context "when diff is not present" do
        it { is_expected.to eq([]) }
      end
    end
  end

  describe "#diff" do
    context "when repository is nil" do
      subject(:predictor) { described_class.new(map, nil) }

      it "raises a clear git repository error" do
        expect { predictor.diff }
          .to raise_error(Crystalball::GitRepo::UnavailableError, Crystalball::GitRepo::UNAVAILABLE_MESSAGE)
      end
    end

    context "when predictor is required directly" do
      let(:script) do
        <<~RUBY
          require "crystalball/predictor"

          begin
            Crystalball::Predictor.new(nil, nil).diff
          rescue Crystalball::GitRepo::UnavailableError => e
            raise unless e.message == Crystalball::GitRepo::UNAVAILABLE_MESSAGE
          else
            raise "expected Crystalball::GitRepo::UnavailableError"
          end
        RUBY
      end

      it "raises the clear git repository error" do
        _, stderr, status = Open3.capture3(
          RbConfig.ruby, "-Ilib", "-e", script, chdir: Pathname(__dir__).join("../..").expand_path
        )

        expect(status).to be_success, stderr
      end
    end
  end
end
