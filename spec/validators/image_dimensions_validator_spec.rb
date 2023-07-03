require "rails_helper"

RSpec.describe ImageDimensionsValidator, type: :validator do
  subject(:image_dimensions_instance) { image_dimensions_test_model.new(image: sample_image) }

  let(:image_dimensions_test_model) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :image, :upload_dimensions

      validates :image, image_dimensions: { min_width: 648, min_height: 648, max_width: 8192, max_height: 8192 }

      def self.name
        "ImageDimensionsTestModel"
      end
    end
  end

  before do
    allow(image_dimensions_instance).to receive(:upload_dimensions).and_return(width:, height:)
  end

  context "when image has dimensions less than minimum" do
    let(:width) { 649 }
    let(:height) { 647 }

    it { is_expected.to be_invalid }

    it "assigns a default error message" do
      expect { image_dimensions_instance.valid? }.to change(image_dimensions_instance.errors, :count).by 1
      image_dimensions_instance.valid?
      expect(image_dimensions_instance.errors.full_messages).to include "Image is 649x647 pixels. The minimum requirement is 648x648 pixels"
    end
  end

  context "when image has dimensions equal to the minimum" do
    let(:width) { 648 }
    let(:height) { 648 }

    it { is_expected.to be_valid }
  end

  context "when image has dimensions over the minimum" do
    let(:width) { 649 }
    let(:height) { 649 }

    it { is_expected.to be_valid }
  end

  context "when image has dimensions under the minimum" do
    let(:width) { 640 }
    let(:height) { 640 }

    it { is_expected.to be_invalid }
  end

  context "when image has dimensions more than the maximum" do
    let(:width) { 8193 }
    let(:height) { 8192 }

    it { is_expected.to be_invalid }

    it "assigns a default error message" do
      expect { image_dimensions_instance.valid? }.to change(image_dimensions_instance.errors, :count).by 1
      image_dimensions_instance.valid?
      expect(image_dimensions_instance.errors.full_messages).to include "Image is 8193x8192 pixels. The maximum permitted is 8192x8192 pixels"
    end
  end

  context "when image has dimensions equal to the maximum" do
    let(:width) { 8192 }
    let(:height) { 8192 }

    it { is_expected.to be_valid }
  end
end
