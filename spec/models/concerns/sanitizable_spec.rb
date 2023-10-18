require "rails_helper"

RSpec.describe Sanitizable do
  subject(:sanitizable_instance) do
    sanitizable_test_model.new(
      color: " Orange3 ",
      shape: " Square ",
      flavor: " Strawberry2 ",
      smell: " Rancid ",
    )
  end

  let(:sanitizable_test_model) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      def persisted?
        false
      end

      attr_accessor :color, :shape, :flavor, :smell

      include Sanitizable
      sanitize_fields :color, strip: true
      sanitize_fields :shape, downcase: true
      sanitize_fields :flavor, downcase: true, strip: true, remove_digits: true
    end
  end

  describe "when model is validated" do
    before do
      sanitizable_instance.valid?
    end

    it "removes digits and white space when requested" do
      expect(sanitizable_instance.color).to match(/\AOrange3\z/i)
      expect(sanitizable_instance.flavor).to match(/\AStrawberry\z/i)
    end

    it "downcases when requested" do
      expect(sanitizable_instance.shape).to match(/square/)
      expect(sanitizable_instance.flavor).to match(/strawberry/)
    end

    it "leaves other fields unchanged" do
      expect(sanitizable_instance.smell).to eql(" Rancid ")
    end
  end
end
