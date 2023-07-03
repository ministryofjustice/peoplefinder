# == Schema Information
#
# Table name: profile_photos
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime
#  updated_at :datetime
#

require "rails_helper"

RSpec.describe ProfilePhoto, type: :model do
  subject(:profile_photo) { build_stubbed(:profile_photo) }

  it { is_expected.to respond_to :upload_dimensions }
  it { is_expected.to respond_to :crop_x }
  it { is_expected.to respond_to :crop_y }
  it { is_expected.to respond_to :crop_w }
  it { is_expected.to respond_to :crop_h }

  it "has one person" do
    person_association = described_class.reflect_on_association(:person).macro
    expect(person_association).to be :has_one
  end

  it "stores upload dimensions" do
    expect(profile_photo.upload_dimensions).to eq width: 648, height: 648
  end

  describe "#crop" do
    it "crops the image" do
      expect(profile_photo.image).to receive(:recreate_versions!)
      profile_photo.crop(1, 2, 3, 4)
      expect(profile_photo.crop_x).to eq(1)
      expect(profile_photo.crop_y).to eq(2)
      expect(profile_photo.crop_w).to eq(3)
      expect(profile_photo.crop_h).to eq(4)
    end

    it "accepts a specific version to crop" do
      expect(profile_photo.image).to receive(:recreate_versions!).with(:medium)
      profile_photo.crop(1, 2, 3, 4, :medium)
    end

    it "defaults to cropping all versions" do
      expect(profile_photo.image).to receive(:recreate_versions!).with(no_args)
      profile_photo.crop(1, 2, 3, 4)
    end
  end

  describe "validations" do
    subject(:profile_photo) { build(:profile_photo) }

    context "with file" do
      context "with extension is allowlisted" do
        it do
          profile_photo.image = non_allowlist_image
          expect(profile_photo).to be_invalid
        end

        it do
          profile_photo.image = valid_image
          expect(profile_photo).to be_valid
        end
      end

      context "when size must be less than or equal to 6M" do
        it do
          allow(profile_photo.image).to receive(:size).and_return 6.001.megabytes
          expect(profile_photo).to be_invalid
        end

        it do
          allow(profile_photo.image).to receive(:size).and_return 6.megabytes
          expect(profile_photo).to be_valid
        end
      end
    end

    context "with image dimensions" do
      context "when it is greater than 648x648 pixels" do
        it do
          allow(profile_photo).to receive(:upload_dimensions).and_return(width: 649, height: 647) # rubocop:disable RSpec/SubjectStub
          expect(profile_photo).to be_invalid
        end

        it do
          allow(profile_photo).to receive(:upload_dimensions).and_return(width: 648, height: 648) # rubocop:disable RSpec/SubjectStub
          expect(profile_photo).to be_valid
        end
      end

      context "when it is less than or equal to 8192x8192 pixels" do
        it do
          allow(profile_photo).to receive(:upload_dimensions).and_return(width: 8193, height: 8192) # rubocop:disable RSpec/SubjectStub
          expect(profile_photo).to be_invalid
        end

        it do
          allow(profile_photo).to receive(:upload_dimensions).and_return(width: 8192, height: 8192) # rubocop:disable RSpec/SubjectStub
          expect(profile_photo).to be_valid
        end
      end
    end

    context "when a saving file" do
      context "with non image" do
        subject(:profile_photo) { build :profile_photo, :non_image }

        it "raises expected error" do
          expect { profile_photo.save! }.to raise_error ActiveRecord::RecordInvalid, /not allowed to upload "csv" files, allowed types: jpg, jpeg, gif, png/
        end
      end

      context "with very large file" do
        subject(:profile_photo) { build :profile_photo }

        before do
          allow(profile_photo.image).to receive(:size).and_return 6.001.megabytes
        end

        it "raises expected error" do
          expect { profile_photo.save! }.to raise_error ActiveRecord::RecordInvalid, /file size, 6 MB, is too large/
        end
      end

      context "with unwhitelisted extension" do
        subject(:profile_photo) { build :profile_photo, :invalid_extension }

        it "raises expected error" do
          expect { profile_photo.save! }.to raise_error ActiveRecord::RecordInvalid, /not allowed to upload "bmp" files, allowed types: jpg, jpeg, gif, png/
        end
      end

      context "with too small dimensions" do
        subject(:profile_photo) { build :profile_photo, :too_small_dimensions }

        it "raises expected error" do
          expect { profile_photo.save! }.to raise_error ActiveRecord::RecordInvalid, /is 510x512 pixels. The minimum requirement is 648x648 pixels/
        end
      end

      context "with too large dimensions" do
        subject(:profile_photo) { build :profile_photo }

        before do
          allow(profile_photo).to receive(:upload_dimensions).and_return(width: 8192, height: 8193) # rubocop:disable RSpec/SubjectStub
        end

        it "raises expected error" do
          expect { profile_photo.save! }.to raise_error ActiveRecord::RecordInvalid, /is 8192x8193 pixels. The maximum permitted is 8192x8192 pixels/
        end
      end
    end
  end
end
