module Peoplefinder
  class SuggestionMailer < ActionMailer::Base
    layout 'peoplefinder/email'

    def person_email(person, suggester, suggestion_hash)
      @person = person
      @suggester = suggester
      @suggestion = Peoplefinder::Suggestion.new(suggestion_hash)
      mail to: person.email
    end

    def team_admin_email(person, suggester, suggestion_hash, admin)
      @person = person
      @suggester = suggester
      @suggestion = Peoplefinder::Suggestion.new(suggestion_hash)
      mail to: admin.email
    end
  end
end
