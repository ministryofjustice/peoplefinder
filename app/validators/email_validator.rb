class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    email_address = EmailAddress.new(value)

    if email_address.valid_format?
      unless email_address.permitted_domain?
        record.errors.add(attribute, :invalid_domain, options)
      end
    else
      record.errors.add(attribute, :invalid_format, options)
    end
  end
end
