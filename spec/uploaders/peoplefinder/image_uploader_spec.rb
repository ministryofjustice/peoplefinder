require 'rails_helper'

RSpec.describe Peoplefinder::ImageUploader, type: :uploader do
  include CarrierWave::Test::Matchers
  let(:person) { create(:person, image: File.open(sample_image)) }

  before do
    described_class.enable_processing = true
  end

  it 'creates default image sizes' do
    expect(person.image.croppable).to be_no_larger_than(1024, 1024)
    expect(person.image.medium).to be_no_larger_than(512, 512)
  end

  it 'crops the medium image and leaves the croppable version intact' do
    person.assign_attributes(crop_x: 10, crop_y: 10, crop_w: 20, crop_h: 20)
    person.image.recreate_versions!

    expect(person.image.croppable).to be_no_larger_than(1024, 1024)
    expect(person.image.medium).to have_dimensions(20, 20)
  end

  after do
    described_class.enable_processing = false
  end
end
