module SpecSupport
  module Email
    def last_email
      ActionMailer::Base.deliveries.last
    end

    def links_in_email(delivery)
      email_contains(delivery, /https?:\S+/)
    end

    def email_contains(delivery, matcher)
      delivery.body.encoded.scan(matcher)
    end

    def check_email_has_token_link_to(person)
      expect(last_email.body.encoded).to match("http.*tokens\/#{ Peoplefinder::Token.last.to_param }.*?desired_path=%2Fpeople%2F*#{ person.to_param }")
    end
  end
end
