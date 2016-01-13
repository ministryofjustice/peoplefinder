class SearchController < ApplicationController
  def index
    @query = query
    @people = PersonSearch.new.perform_search(@query)
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
