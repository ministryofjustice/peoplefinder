class SuggestionMailer < ApplicationMailer
  def person_email(person, suggester, suggestion_hash)
    suggestion = Suggestion.new(suggestion_hash)

    set_template('481a02b5-5783-453a-87c4-d7ec1d55842e')

    set_personalisation(
      person_name: person.given_name,
      suggester_name: suggester.name,
      suggestion_missing_fields: suggestion.missing_fields_info.presence || "N/A",
      suggestion_incorrect_fields: suggestion.incorrect_fields_info.join(', ').presence || "N/A",
      person_url: person_url(person)
    )

    mail(to: person.email)
  end

  def team_admin_email(person, suggester, suggestion_hash, admin)
    suggestion = Suggestion.new(suggestion_hash)

    set_template('48109d13-7b60-44b8-8dc1-3bded70468cc')

    set_personalisation(
      admin_name: admin.given_name,
      person_name: person.name,
      suggester_name: suggester.name,
      duplicate_profile: suggestion.duplicate_profile,
      inappropriate_content: suggestion.inappropriate_content,
      inappropriate_content_info: inappropriate_content_info(suggestion),
      person_left: suggestion.person_left,
      person_left_info: person_left_info(suggestion),
      person_url: person_url(person)
    )

    mail(to: admin.email)
  end

  def inappropriate_content_info(suggestion)
    if suggestion.inappropriate_content_info.present?
      "They provided the following information about inappropriate content: #{suggestion.inappropriate_content_info}"
    else
      ""
    end
  end

  def person_left_info(suggestion)
    if suggestion.person_left_info.present?
      "They provided the following information about the person leaving: #{suggestion.person_left_info}"
    else
      ""
    end
  end
end
