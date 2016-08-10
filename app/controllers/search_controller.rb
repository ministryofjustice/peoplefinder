class SearchController < ApplicationController

  helper_method :matches_exist?

  def index
    @query = query
    @teams, @exact_team_exists = GroupSearch.new(@query).perform_search
    @people, @person_match_exists = PersonSearch.new(@query).perform_search
  end

  private

  def matches_exist?
    @exact_team_exists || @person_match_exists
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
