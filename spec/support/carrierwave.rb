module SpecSupport
  module Carrierwave
    RSpec.configure do |config|
      config.after(:suite) do
        FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
      end
    end

    def sample_image
      File.join(Peoplefinder::Engine.root, 'spec', 'fixtures', 'placeholder.png')
    end
  end
end
