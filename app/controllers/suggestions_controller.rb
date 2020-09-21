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
    params.require(:suggestion).permit!
  end

  def person_params
    params.require(:person_id)
  end
end
