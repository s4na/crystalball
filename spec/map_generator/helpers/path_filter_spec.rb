# frozen_string_literal: true

require "spec_helper"

describe Crystalball::MapGenerator::Helpers::PathFilter do
  subject(:path_filter) { Class.new.tap { |c| c.include described_class } }

  let(:exclude_prefixes) { [] }
  let(:root) { "/foo" }
  let(:paths) { ["/foo/file.rb", "/abc/file1.rb", "/foo/file_1.rb", "/foo/filtered_file.rb"] }

  it "returns only paths relative too root" do
    expect(path_filter.new(root).filter(paths)).to eq(%w[file.rb file_1.rb filtered_file.rb])
  end

  it "returns filtered paths" do
    expect(path_filter.new(root, exclude_prefixes: ["file_1.rb", /filtered/]).filter(paths)).to eq(%w[file.rb])
  end
end
