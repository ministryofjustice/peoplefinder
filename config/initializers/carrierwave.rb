CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.storage = :file
  else
    config.storage = :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['S3_KEY'],
      aws_secret_access_key: ENV['S3_SECRET']
    }
    config.fog_directory  = ENV['S3_BUCKET_NAME']
  end
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end

  module DirHelpers
    def base_upload_dir
      ""
    end
  end
end

if Rails.env.test?
  ImageUploader
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def base_upload_dir
        "#{Rails.root}/spec/support/"
      end
    end
  end
end
