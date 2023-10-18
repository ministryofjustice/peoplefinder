module Placeholder
  extend ActiveSupport::Concern

  def placeholder(field)
    I18n.t(field, scope: "placeholders.#{self.class.model_name.i18n_key}")
  end

  def with_placeholder_default(field)
    value = send(field)
    value.presence || placeholder(field)
  end
end
