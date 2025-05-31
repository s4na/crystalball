# frozen_string_literal: true

RSpec.shared_examples "base strategy" do
  it { is_expected.to respond_to :after_register, :after_start, :before_finalize, :run_before, :run_after }
end
