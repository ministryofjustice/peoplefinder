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
      expect(subject.image).to receive(:recreate_versions!).with(:medium)
      subject.crop(1, 2, 3, 4, :medium)
    end

    it 'defaults to cropping all versions' do
      expect(subject.image).to receive(:recreate_versions!).with(no_args)
      subject.crop(1, 2, 3, 4)
    end
  end

  describe 'validations' do
    subject { build(:profile_photo) }

    context 'file' do
      context 'extension is whitelisted' do
        it do
          subject.image = non_white_list_image
          is_expected.to be_invalid
        end

        it do
          subject.image = valid_image
          is_expected.to be_valid
        end
      end

      context 'size must be less than or equal to 6M' do
        it do
          allow(subject.image).to receive(:size).and_return 6.001.megabytes
          is_expected.to be_invalid
        end

        it do
          allow(subject.image).to receive(:size).and_return 6.megabytes
          is_expected.to be_valid
        end
      end
    end

    context 'image dimensions' do
      context 'must be greater than 648x648 pixels' do
        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 649, height: 647)
          is_expected.to be_invalid
        end

        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 648, height: 648)
          is_expected.to be_valid
        end
      end

      context 'must be less than or equal to 8192x8192 pixels' do
        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 8193, height: 8192)
          is_expected.to be_invalid
        end

        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 8192, height: 8192)
          is_expected.to be_valid
        end
      end
    end

    context 'saving file' do
      context 'with non image' do
        subject { build :profile_photo, :non_image }

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /not allowed to upload "csv" files, allowed types: jpg, jpeg, gif, png/
        end
      end

      context 'with very large file' do
        subject { build :profile_photo }

        before do
          allow(subject.image).to receive(:size).and_return 6.001.megabytes
        end

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /file size, 6 MB, is too large/
        end
      end

      context 'with unwhitelisted extension' do
        subject { build :profile_photo, :invalid_extension }

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /not allowed to upload "bmp" files, allowed types: jpg, jpeg, gif, png/
        end
      end

      context 'with too small dimensions' do
        subject { build :profile_photo, :too_small_dimensions }

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /is 510x512 pixels. The minimum requirement is 648x648 pixels/
        end
      end

      context 'with too large dimensions' do
        subject { build :profile_photo }

        before do
          allow(subject).to receive(:upload_dimensions).and_return(width: 8192, height: 8193)
        end

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /is 8192x8193 pixels. The maximum permitted is 8192x8192 pixels/
        end
      end
    end

  end

end
