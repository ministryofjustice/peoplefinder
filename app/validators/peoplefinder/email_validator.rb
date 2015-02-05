require 'peoplefinder'

module Peoplefinder
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      email_address = EmailAddress.new(value)

      if email_address.valid_format?
        unless email_address.valid_domain?
          record.errors[attribute] <<
              (options[:message_domain] || 'does not have a supported domain')
        end
      else
        record.errors[attribute] <<
            (options[:message_format] || 'is not a valid email')
      end
    end
  end
end
