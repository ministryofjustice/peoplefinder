class ProfilePhoto < ActiveRecord::Base
  has_one :person
  mount_uploader :image, ImageUploader
end
