CarrierWave.configure do |config|
  if ENV["S3_KEY"] && ENV["S3_SECRET"] && ENV["S3_BUCKET_NAME"]
    config.storage = :fog
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV["S3_KEY"],
      aws_secret_access_key: ENV["S3_SECRET"],
      region: ENV["S3_REGION"],
    }
    config.fog_directory = ENV["S3_BUCKET_NAME"]
    config.fog_public = false
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :file
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
      Rails.env.test? ? Rails.root.join("spec/support/") : ""
    end
  end
end

if Rails.env.test?
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?

    klass.class_eval do
      def base_upload_dir
        Rails.root.join("spec/support/")
      end
    end
  end
end
