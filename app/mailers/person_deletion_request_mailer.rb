class PersonDeletionRequestMailer < ActionMailer::Base
  layout 'email'

  def deletion_request(reporter:, person:, note:)
    @reporter = reporter
    @person = person
    @note = note

    mail to: Rails.configuration.support_email,
      reply_to: reporter.email
  end
end
