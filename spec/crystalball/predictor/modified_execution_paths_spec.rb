# frozen_string_literal: true

require "git"
require "spec_helper"

describe Crystalball::Predictor::ModifiedExecutionPaths do
  subject(:predictor) { described_class.new }
  let(:repository) { Git::Base.new }
  let(:path1) { "file1.rb" }
  let(:file_diff1) { Crystalball::SourceDiff::FileDiff.new(Git::Diff::DiffFile.new(repository, path: path1)) }
  let(:diff) { [file_diff1] }
  let(:map) { instance_double("Crystalball::MapGenerator::ExecutionMap", example_groups: example_groups) }
  let(:example_groups) { {"spec_file" => [path1]} }
  let(:path1) { "file1.rb" }
  let(:patch) { "@@ -1,3 +1,3 @@\n line 1\n-old line\n+new line\n line 3" }

  describe "#call" do
    subject { predictor.call(diff, map) }

    it { is_expected.to eq(["./spec_file"]) }

    context "when no files match diff" do
      let(:example_groups) { {"spec_file" => %w[file2.rb]} }

      it { is_expected.to eq([]) }
    end

    context "when some files match diff" do
      let(:example_groups) { {"spec_file" => %w[file2.rb file1.rb]} }

      it { is_expected.to eq(["./spec_file"]) }
    end

    context "when diff contains other unrelated files" do
      let(:file_diff2) { Crystalball::SourceDiff::FileDiff.new(Git::Diff::DiffFile.new(repository, path: "file2.rb")) }
      let(:diff) { [file_diff1, file_diff2] }

      it { is_expected.to eq(["./spec_file"]) }
    end

    context "when line-level coverage map has executed changed lines" do
      let(:file_diff1) do
        Crystalball::SourceDiff::FileDiff.new(
          Git::Diff::DiffFile.new(repository, type: "modified", path: path1, patch: patch)
        )
      end
      let(:example_groups) { {"spec_file" => [{path1 => [2]}]} }

      it { is_expected.to eq(["./spec_file"]) }
    end

    context "when line-level coverage map has not executed changed lines" do
      let(:file_diff1) do
        Crystalball::SourceDiff::FileDiff.new(
          Git::Diff::DiffFile.new(repository, type: "modified", path: path1, patch: patch)
        )
      end
      let(:example_groups) { {"spec_file" => [{path1 => [1, 3]}]} }

      it { is_expected.to eq([]) }
    end
  end
end
