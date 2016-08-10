class SearchController < ApplicationController

  helper_method :matches_exist?

  def index
    @query = query
    @team_results = search_teams(@query)
    @people, @person_match_exists = PersonSearch.new(@query).perform_search
  end

  private

  def search_teams(query)
    search = GroupSearch.new(query, SearchResults.new)
    search.perform_search
  end

  def matches_exist?
    @team_results.contains_exact_match || @person_match_exists
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
