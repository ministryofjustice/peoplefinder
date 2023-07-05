class SuggestionsController < ApplicationController
  def new
    @person = Person.friendly.find(person_params)
    authorize @person
    @suggestion = Suggestion.new
  end

  def create
    @suggestion = Suggestion.new(suggestion_params)
    if @suggestion.valid?
      person = Person.friendly.find(person_params)
      authorize person
      @delivery_details =
        SuggestionDelivery.deliver(person, current_user, @suggestion)
      render :create
    else
      render :new
    end
  end

private

  def suggestion_params
    params.require(:suggestion).permit(
      :missing_fields, :missing_fields_info,
      :incorrect_fields, :incorrect_first_name,
      :incorrect_last_name, :incorrect_roles,
      :incorrect_location_of_work, :incorrect_working_days,
      :incorrect_phone_number, :incorrect_pager_number,
      :incorrect_image, :duplicate_profile,
      :inappropriate_content, :inappropriate_content_info,
      :person_left, :person_left_info
    )
  end

  def person_params
    params.require(:person_id)
  end
end
