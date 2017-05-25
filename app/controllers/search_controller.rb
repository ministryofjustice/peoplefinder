class SearchController < ApplicationController
  include SearchHelper

  before_action :set_search_args

  def index
    @team_results = search(GroupSearch) if teams_filter?
    @people_results = search(PersonSearch) if people_filter?
  end

  private

  def search(klass)
    search = klass.new(@query, SearchResults.new)
    search.perform_search
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

  def set_search_args
    @query = query
    @search_filters = (params[:search_filters] || [])
  end

end
