class SuggestionMailer < ApplicationMailer
  helper MailHelper

  def person_email(person, suggester, suggestion_hash)
    @person = person
    @suggester = suggester
    @suggestion = Suggestion.new(suggestion_hash)
    sendmail to: person.email
  end

  def team_admin_email(person, suggester, suggestion_hash, admin)
    @person = person
    @suggester = suggester
    @admin = admin
    @suggestion = Suggestion.new(suggestion_hash)
    sendmail to: admin.email
  end
end
