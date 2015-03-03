module Peoplefinder
  class SuggestionsController < ApplicationController
    def new
      @suggestion = Suggestion.new
    end

    def create
      @suggestion = Suggestion.new(params[:suggestion])
      if @suggestion.valid?
        render text: 'great!'
      else
        render :new
      end
    end
  end
end
