require "rails_helper"

RSpec.describe FileSizeValidator, type: :validator do
  subject(:file_size_test_instance) { file_size_test_model.new(image: sample_image) }

  let(:file_size_test_model) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :image

      validates :image, file_size: { maximum: 6.megabytes }

      def self.name
        "FileSizeTestModel"
      end
    end
  end

  before do
    allow(file_size_test_instance.image).to receive(:size).and_return(file_size)
  end

  context "with an image with byte size over the maximum" do
    let(:file_size) { 6.01.megabytes }

    it { is_expected.to be_invalid }

    it "assigns a default error message" do
      expect { file_size_test_instance.valid? }.to change(file_size_test_instance.errors, :count).by 1
      file_size_test_instance.valid?
      expect(file_size_test_instance.errors.full_messages).to include "Image file size, 6.01 MB, is too large"
    end
  end

  context "with an image with byte size equal to the maximum" do
    let(:file_size) { 6.megabytes }

    it { is_expected.to be_valid }
  end

  context "with an image with byte size under the maximum" do
    let(:file_size) { 5.99.megabytes }

    it { is_expected.to be_valid }
  end
end
