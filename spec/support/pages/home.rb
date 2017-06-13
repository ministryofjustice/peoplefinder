require_relative 'sections/search_form'
require_relative 'sections/about_usage'
require_relative 'sections/department_overview'

module Pages
  class Home < Base
    set_url '/'
    set_url_matcher('')

    element :page_title, '#content h1.cb-page-title'
    element :unsupported_browser_warning, '.cb-unsupported-browser-warning'
    element :create_profile_link, '.new-profile a.add-new-person'

    section :search_form, Sections::SearchForm, 'form.mod-search-form'
    section :about_usage, Sections::AboutUsage, '.cb-about-usage'
    section :department_overview, Sections::DepartmentOverview, '.cb-department-overview'
  end
end
