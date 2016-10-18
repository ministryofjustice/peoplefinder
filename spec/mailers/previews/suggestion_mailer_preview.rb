class SuggestionMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def person_email
    SuggestionMailer.person_email(recipient, instigator, suggestion_hash)
  end

  def team_admin_email
    SuggestionMailer.team_admin_email(recipient, instigator, suggestion_hash, instigator)
  end

  private

  def suggestion_hash
    {
      "missing_fields"=>"1",
      "missing_fields_info"=>"i think there is missing information",
      "incorrect_fields"=>"1",
      "incorrect_first_name"=>"1",
      "incorrect_last_name"=>"1",
      "incorrect_roles"=>"1",
      "incorrect_location_of_work"=>"1",
      "incorrect_working_days"=>"1",
      "incorrect_phone_number"=>"1",
      "incorrect_pager_number"=>"1",
      "incorrect_image"=>"1",
      "duplicate_profile"=>"1",
      "inappropriate_content"=>"1",
      "inappropriate_content_info"=>"Its a bit naughty",
      "person_left"=>"1",
      "person_left_info"=>"they retired"
    }
  end

end
