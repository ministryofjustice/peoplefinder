require 'rails_helper'

RSpec.describe ProfilePhoto, type: :model do
  subject {
    create(:profile_photo)
  }

  it 'should crop the image' do
    expect(subject.image).to receive(:recreate_versions!)
    subject.crop(1, 2, 3, 4)
    expect(subject.crop_x).to eq(1)
    expect(subject.crop_y).to eq(2)
    expect(subject.crop_w).to eq(3)
    expect(subject.crop_h).to eq(4)
  end
end
