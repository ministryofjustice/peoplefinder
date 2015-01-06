module Peoplefinder
  class SearchController < ApplicationController
    def index
      @people = SEARCH_INDEX.search(params[:query], limit: 100)
    end
  end
end
