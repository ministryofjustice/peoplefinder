module SpecSupport
  module Carrierwave
    def sample_image
      File.join(Rails.root, "spec", "fixtures", "placeholder.png")
    end
  end
end
