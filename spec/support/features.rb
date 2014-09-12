module SpecSupport
  #
  # Miscellaneous helpers for feature-writing
  #
  module Features
    def send_introduction(user)
      Introduction.new(user).send
    end

    def last_email
      ActionMailer::Base.deliveries.last
    end

    def links_in_email(delivery)
      delivery.body.encoded.scan(/https?:\S+/)
    end

    def email_contains(delivery, matcher)
      delivery.body.encoded.scan(matcher).first
    end
  end
end
