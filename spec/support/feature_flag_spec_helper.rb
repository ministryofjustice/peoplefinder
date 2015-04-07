module FeatureFlagSpecHelper
  def disable_feature(name)
    feature_flag name, true
  end

  def enable_feature(name)
    feature_flag name, false
  end

  def feature_flag(name, value)
    around(:each) do |example|
      original = Rails.application.config.try(:"disable_#{name}") || false
      Rails.application.config.send :"disable_#{name}=", value

      example.run

      Rails.application.config.send :"disable_#{name}=", original
    end
  end
end
