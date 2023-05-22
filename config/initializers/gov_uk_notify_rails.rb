ActionMailer::Base.add_delivery_method(
  :govuk_notify,
  GovukNotifyRails::Delivery,
  api_key: Rails.configuration.govuk_notify_api_key
)
