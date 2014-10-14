# encoding: utf-8
require 'peoplefinder'

class Peoplefinder::ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::DirHelpers

  # Storage location is configured per-environment in
  # config/initializers/carrierwave.rb

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    '%suploads/%s/%s/%s' % [
      base_upload_dir,
      model.class.to_s.underscore,
      mounted_as,
      model.id
    ]
  end

  def default_url
    [version_name, 'no_photo.png'].compact.join('_')
  end

  version :medium, from_version: :croppable do
    process :crop
    process resize_to_limit: [512, 512]
    process quality: 60
  end

  version :croppable do
    process resize_to_limit: [1024, 1024]
  end

  def crop
    if model.crop_x.present?
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop "#{ w }x#{ h }+#{ x }+#{ y }"
        img
      end
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w[ jpg jpeg gif png ]
  end
end
