require "rails_helper"

RSpec.describe Concerns::Placeholder do
  subject(:test_model_instance) { test_model.new }

  let(:test_model) do
    Class.new do
      extend ActiveModel::Naming
      include Concerns::Placeholder
      attr_accessor :field

      def self.name
        "TestModel"
      end
    end
  end

  describe "#placeholder" do
    it "looks up placeholder text via I18n" do
      expect(test_model_instance.placeholder(:field))
        .to eq("Translation missing: en.placeholders.test_model.field")
    end
  end

  describe "#with_placeholder_default" do
    it "returns the value of a field if present" do
      test_model_instance.field = "EXAMPLE TEXT"
      expect(test_model_instance.with_placeholder_default(:field))
        .to eq("EXAMPLE TEXT")
    end

    it "returns the placeholder text if field is blank" do
      test_model_instance.field = ""
      expect(test_model_instance.with_placeholder_default(:field))
        .to eq("Translation missing: en.placeholders.test_model.field")
    end
  end
end
