# frozen_string_literal: true

require "git"
require "spec_helper"

describe Crystalball::SourceDiff::FileDiff do
  subject(:file_diff) { described_class.new(diff_file) }
  let(:diff_file) { Git::Diff::DiffFile.new(Git::Base.new, type: type, path: "lib/crystalball.rb") }
  let(:type) {}

  %i[modified deleted new].each do |type|
    context "##{type}?" do
      subject { file_diff.send("#{type}?") }

      it { is_expected.to be_falsey }

      context "with correct type" do
        let(:type) { type.to_s }

        it { is_expected.to be_truthy }
      end
    end
  end

  context "#moved?" do
    subject { file_diff.send("moved?") }

    it { is_expected.to be_falsey }

    context "with correct patch" do
      let(:diff_file) { Git::Diff::DiffFile.new(Git::Base.new, type: "modified", path: "lib/crystalball.rb", patch: "rename from lib/crystalball.rb\nrename to lib/crystalball_new.rb") }

      it { is_expected.to be_truthy }
    end
  end

  describe "#relative_path" do
    subject { file_diff.relative_path }
    it { is_expected.to eq("lib/crystalball.rb") }
  end

  describe "#new_relative_path" do
    subject { file_diff.new_relative_path }

    context "when file not moved" do
      it { is_expected.to eq("lib/crystalball.rb") }
    end

    context "when file moved" do
      let(:diff_file) { Git::Diff::DiffFile.new(Git::Base.new, type: "modified", path: "lib/crystalball.rb", patch: "rename from lib/crystalball.rb\nrename to lib/crystalball_new.rb") }

      it { is_expected.to eq("lib/crystalball_new.rb") }
    end
  end

  describe "#changed_lines" do
    subject { file_diff.changed_lines }

    let(:type) { "modified" }
    let(:diff_file) do
      Git::Diff::DiffFile.new(
        Git::Base.new,
        type: type,
        path: "lib/crystalball.rb",
        patch: "@@ -2,4 +2,5 @@\n context\n-removed\n+added\n unchanged\n+another"
      )
    end

    it { is_expected.to eq([3, 5]) }

    context "when an added line starts with plus signs" do
      let(:diff_file) do
        Git::Diff::DiffFile.new(
          Git::Base.new,
          type: type,
          path: "lib/crystalball.rb",
          patch: "@@ -1,2 +1,3 @@\n context\n+++value\n unchanged"
        )
      end

      it { is_expected.to eq([2]) }
    end

    context "with a deleted file" do
      let(:type) { "deleted" }

      it { is_expected.to eq([]) }
    end
  end

  describe "#inserted_lines" do
    subject { file_diff.inserted_lines }

    let(:type) { "modified" }
    let(:diff_file) do
      Git::Diff::DiffFile.new(
        Git::Base.new,
        type: type,
        path: "lib/crystalball.rb",
        patch: "@@ -2,4 +2,5 @@\n context\n-removed\n+added\n unchanged\n+another"
      )
    end

    it { is_expected.to eq([5]) }
  end

  describe "#method_missing" do
    it "delegates missing methods to DiffFile" do
      expect(file_diff.path).to eq("lib/crystalball.rb")
      expect(file_diff.method(:path).call).to eq("lib/crystalball.rb")
    end
  end
end
