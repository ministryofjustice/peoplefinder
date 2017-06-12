require 'rails_helper'

RSpec.describe ImageDimensionsValidator, type: :validator do
  class ImageDimensionsTestModel
    include ActiveModel::Model

    attr_accessor :image, :upload_dimensions
    validates :image, image_dimensions: { min_width: 648, min_height: 648, max_width: 8192, max_height: 8192 }
  end

  subject { ImageDimensionsTestModel.new(image: sample_image) }

  before do
    allow(subject).to receive(:upload_dimensions).and_return(width: width, height: height)
  end

  context 'image with dimensions less than minimum' do
    let(:width) { 649 }
    let(:height) { 647 }
    it { is_expected.to be_invalid }

    it 'assigns a default error message' do
      expect { subject.valid? }.to change(subject.errors, :count).by 1
      subject.valid?
      expect(subject.errors.full_messages).to include "Image is 649x647 pixels. The minimum requirement is 648x648 pixels"
    end
  end

  context 'image with dimensions equal to the minimum' do
    let(:width) { 648 }
    let(:height) { 648 }
    it { is_expected.to be_valid }
  end

  context 'image with dimensions over the minimum' do
    let(:width) { 649 }
    let(:height) { 649 }
    it { is_expected.to be_valid }
  end

  context 'image with dimensions more than the maximum' do
    let(:width) { 8193 }
    let(:height) { 8192 }
    it { is_expected.to be_invalid }

    it 'assigns a default error message' do
      expect { subject.valid? }.to change(subject.errors, :count).by 1
      subject.valid?
      expect(subject.errors.full_messages).to include "Image is 8193x8192 pixels. The maximum permitted is 8192x8192 pixels"
    end
  end

  context 'image with dimensions equal to the maximum' do
    let(:width) { 8192 }
    let(:height) { 8192 }
    it { is_expected.to be_valid }
  end

  context 'image with dimensions under the maximum' do
    let(:width) { 648 }
    let(:height) { 648 }
    it { is_expected.to be_valid }
  end

end
