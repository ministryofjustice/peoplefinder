class SearchController < ApplicationController

  helper_method :matches_exist?

  def index
    @query = query
    @team_results = search(GroupSearch)
    @people_results = search(PersonSearch)
  end

  private

  def search(klass)
    search = klass.new(@query, SearchResults.new)
    search.perform_search
  end

  def matches_exist?
    @team_results.contains_exact_match || @people_results.contains_exact_match
  end

  def can_add_person_here?
    true
  end

  def query
    input = params[:query]
    input.encode(Encoding::UTF_32LE)
    input
  rescue Encoding::InvalidByteSequenceError
    ''
  end
end
