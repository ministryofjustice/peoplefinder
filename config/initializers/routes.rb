# Here we ensure that url_for can be use by active model serializers
Rails.application.routes.default_url_options =
  Rails.application.config.action_mailer.default_url_options
