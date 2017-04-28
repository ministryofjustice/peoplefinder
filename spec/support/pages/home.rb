require_relative 'sections/search_form'

module Pages
  class Home < Base
    set_url '/'
    set_url_matcher('')

    element :page_title, '#content h1.cb-page-title'
    section :search_form, Sections::SearchForm, 'form.mod-search-form'
  end
end
