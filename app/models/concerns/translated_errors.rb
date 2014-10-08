module TranslatedErrors
  def add_translated_error(field, partial_key, options = {})
    full_key = [self.class.model_name.plural, 'errors', partial_key].join('.')
    errors.add field, I18n.t(full_key, options)
  end
end
