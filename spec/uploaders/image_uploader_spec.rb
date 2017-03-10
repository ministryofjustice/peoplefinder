require 'rails_helper'

RSpec.describe ImageUploader, type: :uploader do
  include CarrierWave::Test::Matchers
  include PermittedDomainHelper

  before do
    described_class.enable_processing = true
  end

  after do
    described_class.enable_processing = false
  end

  context 'with a profile photo object' do
    subject { profile_photo.image }
    let(:profile_photo) { create(:profile_photo) }

    context '#dimensions' do
      it { is_expected.to respond_to :dimensions }

      it 'retrieves dimensions of stored object' do
        expect(subject.dimensions).to eq width: 648, height: 648
      end
    end

    it 'stores dimensions on the model temporarily' do
      expect(profile_photo.upload_dimensions).to eq width: 648, height: 648
      expect(ProfilePhoto.find(profile_photo.id).upload_dimensions).to eq nil
    end

    it 'creates default image sizes' do
      expect(subject.croppable).to have_dimensions(648, 648)
      expect(subject.medium).to be_no_larger_than(512, 512)
    end

    it 'crops the medium image and leaves the croppable version intact' do
      profile_photo.assign_attributes(crop_x: 10, crop_y: 10, crop_w: 20, crop_h: 20)
      subject.recreate_versions!

      expect(subject.croppable).to have_dimensions(648, 648)
      expect(subject.medium).to have_dimensions(20, 20)
    end

    it 'has a consistent path' do
      # If you change this, you must also consider what to do with legacy image uploads.
      expect(subject.store_dir).
        to eq("#{Rails.root}/spec/support/uploads/peoplefinder/profile_photo/image/#{profile_photo.id}")
    end
  end

  context 'with a person object' do
    let(:person) { create(:person, image: sample_image) }
    subject { person.legacy_image }

    it 'has a consistent path' do
      expect(subject.store_dir).
        to eq("#{Rails.root}/spec/support/uploads/peoplefinder/person/image/#{person.id}")
    end
  end
end
