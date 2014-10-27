module SpecSupport
  module FeatureFlags
    def without_feature(feature_name, &_block)
      old_value = Rails.configuration.try("disable_#{feature_name}") || false
      Rails.application.config.send(:"disable_#{feature_name}=", true)

      yield

      Rails.application.config.send(:"disable_#{feature_name}=", old_value)
    end
  end
end
