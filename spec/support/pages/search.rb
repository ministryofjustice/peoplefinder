Dir[File.expand_path('../sections/search*.rb', __FILE__)].each { |f| require f }

module Pages
  class Search < Base
    set_url_matcher(/search\?.*/)

    element :search_result_summary, '.cb-search-result-summary'

    section :search_form, Sections::SearchForm, 'form#mod-search-form'
    section :search_filters_form, Sections::SearchFiltersForm, 'form#mod-search-filter-form'
    section :search_results, Sections::SearchResults, '.cb-search-results'
    section :search_footer, Sections::SearchFooter, '.cb-search-footer'
  end
end
