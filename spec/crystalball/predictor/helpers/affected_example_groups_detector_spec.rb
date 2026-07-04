# frozen_string_literal: true

require "spec_helper"

RSpec.describe Crystalball::Predictor::Helpers::AffectedExampleGroupsDetector do
  subject(:detector) { detector_class.new }

  let(:detector_class) do
    Class.new do
      include Crystalball::Predictor::Helpers::AffectedExampleGroupsDetector
    end
  end

  let(:map) { instance_double(Crystalball::ExecutionMap, example_groups: example_groups) }

  describe "#detect_examples" do
    subject(:detect_examples) { detector.detect_examples(files, map) }

    let(:files) { ["app/models/user.rb", "app/services/create_user.rb"] }
    let(:example_groups) do
      {
        "spec/models/user_spec.rb" => ["app/models/user.rb"],
        "spec/models/project_spec.rb" => ["app/models/project.rb"],
        "spec/services/create_user_spec.rb" => ["app/services/create_user.rb", "app/models/user.rb"]
      }
    end

    it "returns example group uids whose used files include changed files" do
      expect(detect_examples).to eq(["spec/models/user_spec.rb", "spec/services/create_user_spec.rb"])
    end

    context "when no example groups use changed files" do
      let(:files) { ["app/controllers/users_controller.rb"] }

      it { is_expected.to eq([]) }
    end

    context "when changed files contain duplicates" do
      let(:files) { ["app/models/user.rb", "app/models/user.rb"] }

      it "returns each matching example group once" do
        expect(detect_examples).to eq(["spec/models/user_spec.rb", "spec/services/create_user_spec.rb"])
      end
    end

    context "when there are no changed files" do
      let(:files) { [] }

      it { is_expected.to eq([]) }
    end
  end
end
