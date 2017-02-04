# == Schema Information
#
# Table name: profile_photos
#
#  id         :integer          not null, primary key
#  image      :string
#  created_at :datetime
#  updated_at :datetime
#

class ProfilePhoto < ActiveRecord::Base
  has_one :person
  mount_uploader :image, ImageUploader

  validates :image, file_size: { maximum: 3.megabytes }

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  def crop(x, y, w, h, versions = [])
    self.crop_x = x
    self.crop_y = y
    self.crop_w = w
    self.crop_h = h
    image.recreate_versions!(*versions)
  end

end
