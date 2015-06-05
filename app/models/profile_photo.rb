class ProfilePhoto < ActiveRecord::Base
  has_one :person
  mount_uploader :image, ImageUploader
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  def crop(x, y, w, h)
    self.crop_x = x
    self.crop_y = y
    self.crop_w = w
    self.crop_h = h
    image.recreate_versions!
  end
end
