module SpecSupport
  #
  # Miscellaneous helpers for feature-writing
  #
  module Features
    def send_introduction(user)
      IntroductionNotification.new(user).notify
    end

    def last_email
      ActionMailer::Base.deliveries.last
    end

    def links_in_email(delivery)
      email_contains(delivery, /https?:\S+/)
    end

    def email_contains(delivery, matcher)
      delivery.body.encoded.scan(matcher)
    end

    def click_first_link(*args)
      first(:link, *args).click
    end
  end
end
