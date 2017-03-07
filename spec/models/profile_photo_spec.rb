# == Schema Information
#
# Table name: profile_photos
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ProfilePhoto, type: :model do
  subject { create(:profile_photo) }

  it { is_expected.to respond_to :upload_dimensions }
  it { is_expected.to respond_to :crop_x }
  it { is_expected.to respond_to :crop_y }
  it { is_expected.to respond_to :crop_w }
  it { is_expected.to respond_to :crop_h }

  it 'has one person' do
    person_association = described_class.reflect_on_association(:person).macro
    expect(person_association).to eql :has_one
  end

  it 'stores upload dimensions' do
    expect(subject.upload_dimensions).to eq width: 648, height: 648
    subject
  end

  describe '#crop' do
    it 'crops the image' do
      expect(subject.image).to receive(:recreate_versions!)
      subject.crop(1, 2, 3, 4)
      expect(subject.crop_x).to eq(1)
      expect(subject.crop_y).to eq(2)
      expect(subject.crop_w).to eq(3)
      expect(subject.crop_h).to eq(4)
    end

    it 'accepts a specific version to crop' do
      expect(subject.image).to receive(:recreate_versions!).with(:preview)
      subject.crop(1, 2, 3, 4, :preview)
    end

    it 'defaults to cropping all versions' do
      expect(subject.image).to receive(:recreate_versions!).with(no_args)
      subject.crop(1, 2, 3, 4)
    end
  end

  describe 'validations' do
    subject { build(:profile_photo) }

    it 'validates file size not to exceed 6M' do
      allow(subject.image).to receive(:size).and_return 6.001.megabytes
      expect(subject).to be_invalid
      expect(subject.errors[:image].first).to match(/file size.*too large/)
      allow(subject.image).to receive(:size).and_return 6.megabytes
      expect(subject).to be_valid
    end

    it 'validates image dimensions to not be less than 648x648 pixels' do
      allow(subject).to receive(:upload_dimensions).and_return(width: 649, height: 647)
      expect(subject).to be_invalid
      expect(subject.errors[:image].first).to match(/dimensions.*649x647.*648x648 pixels/)
      allow(subject).to receive(:upload_dimensions).and_return(width: 648, height: 648)
      expect(subject).to be_valid
    end
  end

end
