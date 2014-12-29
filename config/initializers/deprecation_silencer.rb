current_behavior = ActiveSupport::Deprecation.behavior
ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
  deprecations_to_silence = [
    /cannot be used here as a full URL is required/,
    /`serialized_attributes` is deprecated without replacement/,
    /`#reset_updated_at!` is deprecated and will be removed on Rails 5/
  ]

  return if deprecations_to_silence.any? { |pattern| message =~ pattern }

  Array.wrap(current_behavior).each do |behavior|
    behavior.call(message, callstack)
  end
end
