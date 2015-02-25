module Peoplefinder
  class SearchController < ApplicationController
    def index
      @search = true
      @people = Person.fuzzy_search(params[:query]).records.limit(100)
    end
  end
end
