require_relative 'sections/profile_form'

module Pages
  class EditProfile < SitePrism::Page
    set_url '/people{/slug}/edit'
    set_url_matcher(/people\/([a-zA-Z\-]+)\/edit/)

    section :form, Sections::ProfileForm, '.edit_person'
  end
end
