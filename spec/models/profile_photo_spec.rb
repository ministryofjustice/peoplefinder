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

  it 'has one person' do
    person_association = described_class.reflect_on_association(:person).macro
    expect(person_association).to eql :has_one
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

    it 'validates file size not to exceed 3M' do
      allow(subject.image).to receive(:size).and_return 3.001.megabytes
      expect(subject).to_not be_valid
      expect(subject.errors[:image].first).to match(/file size.*too large/)
      allow(subject.image).to receive(:size).and_return 3.megabytes
      expect(subject).to be_valid
    end
  end

end
