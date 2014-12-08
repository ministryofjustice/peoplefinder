require_relative 'sections/profile_form'

module Pages
  class NewProfile < SitePrism::Page
    set_url '/people/new'
    set_url_matcher(/people\/new/)

    section :form, Sections::ProfileForm, '.new_person'
  end
end
