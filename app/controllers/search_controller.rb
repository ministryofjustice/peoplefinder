class SearchController < ApplicationController
  include SearchHelper

  before_action :set_search_args, except: %i[settings toggle_pg_search]

  def index
    @team_results = search(GroupSearch) if teams_filter?

    @people_results = people_results
  end

  def settings; end

  def toggle_pg_search
    session[:pg_search] = !session[:pg_search]
    redirect_to search_settings_path
  end

private

  def search(klass)
    if pg_search?
      pg_search(klass)
    else
      open_search(klass)
    end
  end

  def open_search(klass)
    search = klass.new(@query, SearchResults.new)
    search.perform_search
  end

  def pg_search(klass)
    search = klass.new(@query, PgSearchResults.new)
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
    ""
  end

  def set_search_args
    @query = query
    @search_filters = params[:search_filters] || []
  end

  def people_results
    return pg_search(PersonPgSearch) if pg_search? && people_filter?

    search(PersonSearch) if people_filter?
  end
end
