module Peoplefinder
  module FeatureHelper
    def feature_disabled?(feature_name)
      Rails.configuration.try('disable_' + feature_name.to_s) || false
    end

    def feature_enabled?(feature_name)
      !feature_disabled?(feature_name)
    end
  end
end
