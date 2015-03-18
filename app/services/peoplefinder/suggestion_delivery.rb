module Peoplefinder
  module SuggestionDelivery
    def self.deliver(person, suggester, suggestion)
      if suggestion.for_person?
        SuggestionMailer.person_email(person, suggester, suggestion).deliver_later
      end

      if suggestion.for_admin?
        person.groups.flat_map(&:leaders).each do |leader|
          SuggestionMailer.team_admin_email(person, suggester, suggestion, leader).deliver_later
        end
      end
    end
  end
end
