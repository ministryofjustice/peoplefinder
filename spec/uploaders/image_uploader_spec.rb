require "rails_helper"

RSpec.describe ImageUploader, type: :uploader do
  include CarrierWave::Test::Matchers
  include PermittedDomainHelper

  before do
    described_class.enable_processing = true
  end

  after do
    described_class.enable_processing = false
  end

  context "with a profile photo object" do
    subject(:image) { profile_photo.image }

    let(:profile_photo) { create(:profile_photo) }

    describe "#dimensions" do
      it { is_expected.to respond_to :dimensions }

      it "retrieves dimensions of stored object" do
        expect(image.dimensions).to eq width: 648, height: 648
        expect(image.medium.dimensions).to eq width: 512, height: 512
      end
    end

    context "when storing uploaded file dimensions" do
      it "in before cache callback" do
        expect_any_instance_of(described_class).to receive :store_upload_dimensions # rubocop:disable RSpec/AnyInstance
        image
      end

      it "unpersisted" do
        expect(profile_photo.upload_dimensions).to eq width: 648, height: 648
        expect(ProfilePhoto.find(profile_photo.id).upload_dimensions).to be_nil
      end
    end

    it "creates default image sizes" do
      expect(image.croppable).to have_dimensions(648, 648)
      expect(image.medium).to be_no_larger_than(512, 512)
    end

    it "crops the medium image and leaves the croppable version intact" do
      profile_photo.assign_attributes(crop_x: 10, crop_y: 10, crop_w: 20, crop_h: 20)
      image.recreate_versions!

      expect(image.croppable).to have_dimensions(648, 648)
      expect(image.medium).to have_dimensions(20, 20)
    end

    it "has a consistent path" do
      # If you change this, you must also consider what to do with legacy image uploads.
      expect(image.store_dir)
        .to eq(Rails.root.join("spec/support/uploads/peoplefinder/profile_photo/image/#{profile_photo.id}").to_s)
    end
  end

  context "when ImageMagick cannot decode the uploaded file" do
    before do
      allow_any_instance_of(described_class).to receive(:minimagick!).and_raise( # rubocop:disable RSpec/AnyInstance
        CarrierWave::ProcessingError, I18n.t(:"errors.messages.processing_error")
      )
    end

    let(:profile_photo) { build(:profile_photo, image: sample_image) }

    it "adds a helpful validation error instead of the generic processing error" do
      expect(profile_photo).not_to be_valid
      expect(profile_photo.errors[:image]).to include("is not in a supported format. Please upload a JPEG, PNG, or GIF.")
    end
  end

  context "with a person object" do
    subject(:legacy_image) { person.legacy_image }

    let(:person) { create(:person, image: sample_image) }

    it "has a consistent path" do
      expect(legacy_image.store_dir)
        .to eq(Rails.root.join("spec/support/uploads/peoplefinder/person/image/#{person.id}").to_s)
    end
  end
end
