class SearchController < ApplicationController
  def index
    @people = PersonSearch.new.fuzzy_search(params[:query]).records.limit(100)
  end

private

  def can_add_person_here?
    true
  end
end
