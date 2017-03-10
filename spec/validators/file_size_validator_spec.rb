require 'rails_helper'

RSpec.describe FileSizeValidator, type: :validator do
  class FileSizeTestModel
    include ActiveModel::Model
    attr_accessor :image
    validates :image, file_size: { maximum: 6.megabytes }
  end

  subject { FileSizeTestModel.new(image: sample_image) }

  before do
    allow(subject.image).to receive(:size).and_return(file_size)
  end

  context 'image with byte size over the maximum' do
    let(:file_size) { 6.01.megabytes }
    it { is_expected.to be_invalid }

    it 'assigns a default error message' do
      expect { subject.valid? }.to change(subject.errors, :count).by 1
      subject.valid?
      expect(subject.errors.full_messages).to include "Image file size, 6.01 MB, is too large"
    end
  end

  context 'image with byte size equal to the maximum' do
    let(:file_size) { 6.megabytes }
    it { is_expected.to be_valid }
  end

  context 'image with byte size under the maximum' do
    let(:file_size) { 5.99.megabytes }
    it { is_expected.to be_valid }
  end

end
