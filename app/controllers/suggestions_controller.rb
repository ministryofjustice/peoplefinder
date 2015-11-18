class SuggestionsController < ApplicationController

  def new
    @person = Person.friendly.find(params[:person_id])
    authorize @person
    @suggestion = Suggestion.new
  end

  def create
    @suggestion = Suggestion.new(params[:suggestion])
    if @suggestion.valid?
      person = Person.friendly.find(params[:person_id])
      authorize person
      @delivery_details =
        SuggestionDelivery.deliver(person, current_user, @suggestion)
      render :create
    else
      render :new
    end
  end
end
