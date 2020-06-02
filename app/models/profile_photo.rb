# == Schema Information
#
# Table name: profile_photos
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime
#  updated_at :datetime
#

class ProfilePhoto < ApplicationRecord
  has_one :person
  mount_uploader :image, ImageUploader

  attr_accessor :upload_dimensions, :crop_x, :crop_y, :crop_w, :crop_h

  validates :image, file_size: { maximum: 6.megabytes }
  validates :image, image_dimensions: { min_width: 648, min_height: 648, max_width: 8192, max_height: 8192 }

  def crop(x, y, w, h, versions = [])
    self.crop_x = x
    self.crop_y = y
    self.crop_w = w
    self.crop_h = h
    image.recreate_versions!(*versions)
  end

end
