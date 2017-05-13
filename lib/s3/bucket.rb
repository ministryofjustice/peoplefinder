require 'aws-sdk'

module S3

  # wrapper for Aws::S3::Bucket
  # adds convenience methods for extracting
  # profile images from current environments S3
  # bucket.
  #
  class Bucket

    # needs to be a key-part that exists in both legacy and current profile image keys/file-paths
    PROFILE_IMAGE_KEY_MATCHER = '/image/'.freeze

    def initialize name = nil, options = {}
      @bucket = aws_s3_bucket name, options
    end

    def profile_image key
      profile_image_object(@bucket.object(key)) if key.include? PROFILE_IMAGE_KEY_MATCHER
    end

    def profile_images
      @bucket.objects.select { |obj| obj.key.include? PROFILE_IMAGE_KEY_MATCHER }.map do |image|
        profile_image_object(image)
      end
    end

    # delegate messages known to the aws s3 bucket to it
    #
    def method_missing(method_name, *args, &block)
      if @bucket.respond_to? method_name.to_sym
        @bucket.__send__(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @bucket.respond_to?(method_name.to_sym) || super
    end

    private

    def profile_image_object object
      ProfileImage.new object
    end

    def aws_s3_client
      aws_access_key_id = ENV['S3_KEY']
      aws_secret_access_key = ENV['S3_SECRET']
      aws_region = ENV['S3_REGION']
      Aws::S3::Client.new(
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        region: aws_region
      )
    end

    def aws_s3_bucket name, options
      aws_s3_bucket_name = name || ENV['S3_BUCKET_NAME']
      Aws::S3::Bucket.new(aws_s3_bucket_name, options.merge(client: aws_s3_client))
    end
  end
end
