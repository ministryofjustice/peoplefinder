require "fastimage"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::DirHelpers

  # Storage location is configured per-environment in
  # config/initializers/carrierwave.rb

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    sprintf("%suploads/peoplefinder/%s/%s/%s", base_upload_dir, model.class.to_s.underscore, mounted_as_without_legacy_prefix, model.id)
  end

  def default_url
    [version_name, "no_photo.png"].compact.join("_")
  end

  process :auto_orient # this should go before all other "process" steps

  def auto_orient
    manipulate! do |image|
      image.tap(&:auto_orient)
    end
  end

  version :croppable do
    before :cache, :store_upload_dimensions
  end

  version :medium, from_version: :croppable do
    process :crop
    process resize_to_limit: [512, 512]
    process quality: 60
  end

  def crop
    if model.crop_x.present?
      manipulate! do |img|
        x, y, w, h = origin_and_dimensions model
        img.crop "#{w}x#{h}+#{x}+#{y}"
        img
      end
    end
  end

  def origin_and_dimensions(model)
    x = model.crop_x.to_i
    y = model.crop_y.to_i
    w = model.crop_w.to_i
    h = model.crop_h.to_i
    [x, y, w, h]
  end

  def mounted_as_without_legacy_prefix
    mounted_as.to_s.sub(/^legacy_/, "")
  end

  # list of permissable file extensions for upload
  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  def dimensions
    w, h = ::MiniMagick::Image.open(url_or_file)[:dimensions]
    { width: w, height: h }
  end

private

  def url_or_file
    if file.respond_to? :file
      file.file
    else
      file.url
    end
  end

  def uploaded_file_dimensions
    w, h = FastImage.size(file.file)
    { width: w, height: h }
  end

  def store_upload_dimensions(_file)
    if model.upload_dimensions.nil?
      model.upload_dimensions = uploaded_file_dimensions
    end
  end
end
