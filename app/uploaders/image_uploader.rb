# encoding: utf-8
class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::DirHelpers
  include CarrierWave::BombShelter

  # Storage location is configured per-environment in
  # config/initializers/carrierwave.rb

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    '%suploads/peoplefinder/%s/%s/%s' % [
      base_upload_dir,
      model.class.to_s.underscore,
      mounted_as_without_legacy_prefix,
      model.id
    ]
  end

  def default_url
    [version_name, 'no_photo.png'].compact.join('_')
  end

  process :auto_orient # this should go before all other "process" steps

  def auto_orient
    manipulate! do |image|
      image.tap(&:auto_orient)
    end
  end

  version :medium, from_version: :croppable do
    process :crop
    process resize_to_limit: [512, 512]
    process quality: 60
  end

  version :croppable

  def crop
    if model.crop_x.present?
      manipulate! do |img|
        x, y, w, h = dimensions model
        img.crop "#{w}x#{h}+#{x}+#{y}"
        img
      end
    end
  end

  def dimensions model
    x = model.crop_x.to_i
    y = model.crop_y.to_i
    w = model.crop_w.to_i
    h = model.crop_h.to_i
    [x, y, w, h]
  end

  def mounted_as_without_legacy_prefix
    mounted_as.to_s.sub(/^legacy_/, '')
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w( jpg jpeg gif png )
  end
end
