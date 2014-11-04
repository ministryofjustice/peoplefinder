module Peoplefinder
  class SearchController < ApplicationController
    def index
      @people = Peoplefinder::SearchIndex.new.search(params[:query], limit: 100)
    end
  end
end
