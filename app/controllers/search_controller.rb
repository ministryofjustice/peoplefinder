class SearchController < ApplicationController
  def index
    @query = query
    @teams = GroupSearch.new(@query).perform_search
    @people, @exact_match_exists = PersonSearch.new(@query).perform_search
  end

  private

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
