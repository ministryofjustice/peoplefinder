module SpecSupport
  module Carrierwave
    RSpec.configure do |config|
      config.after(:suite) do
        FileUtils.rm_rf(Rails.root.join('spec', 'support', 'uploads'))
        FileUtils.rm_rf(Rails.root.join('public', 'uploads', 'tmp'))
      end
    end

    def test_image file_name, extension = 'png'
      Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec', 'fixtures', "#{file_name}.#{extension}")
      )
    end

    def sample_image
      test_image :placeholder
    end

    def valid_image
      test_image :profile_photo_valid
    end

    def too_small_dimensions_image
      test_image :profile_photo_too_small_dimensions
    end

    def large_image
      test_image :profile_photo_large
    end

    def non_white_list_image
      test_image :placeholder, :bmp
    end

  end
end
