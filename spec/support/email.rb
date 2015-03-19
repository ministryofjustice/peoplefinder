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

    def check_email_has_profile_link(person)
      expect(last_email.body.encoded).to match(person_url(person))
    end

    def get_message_part(mail, content_type)
      mail.body.parts.find { |p| p.content_type.match content_type }.body
    end
  end
end
