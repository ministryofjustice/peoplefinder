module SpecSupport
  module Carrierwave
    RSpec.configure do |config|
      config.after(:suite) do
        FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
      end
    end

    def sample_image
      File.join(Rails.root, 'spec', 'fixtures', 'placeholder.png')
    end

    def non_white_list_image
      File.join(Rails.root, 'spec', 'fixtures', 'placeholder.bmp')
    end

  end
end
