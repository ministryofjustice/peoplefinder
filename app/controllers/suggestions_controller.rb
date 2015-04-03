class SuggestionsController < ApplicationController
  def new
    @suggestion = Suggestion.new
    @person     = Person.friendly.find(params[:person_id])
  end

  def create
    @suggestion = Suggestion.new(params[:suggestion])
    if @suggestion.valid?
      person = Person.friendly.find(params[:person_id])
      @delivery_details =
        SuggestionDelivery.deliver(person, current_user, @suggestion)
      render :create
    else
      render :new
    end
  end
end
