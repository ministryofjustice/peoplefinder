require "rails_helper"

RSpec.describe Concerns::ConcatenatedFields do
  subject(:test_model_instance) { test_model.new }

  let(:test_model) do
    Class.new do
      attr_accessor :field_a, :field_b

      include Concerns::ConcatenatedFields
      concatenated_field :concatenated, :field_a, :field_b, join_with: ", "
    end
  end

  it "omits blank fields" do
    test_model_instance.field_a = ""
    test_model_instance.field_b = "bravo"
    expect(test_model_instance.concatenated).to eq("bravo")
  end

  it "joins using the specified join_with value" do
    test_model_instance.field_a = "alpha"
    test_model_instance.field_b = "bravo"
    expect(test_model_instance.concatenated).to eq("alpha, bravo")
  end
end
