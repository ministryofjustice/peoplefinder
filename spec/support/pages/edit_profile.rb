require_relative 'sections/profile_form'

module Pages
  class EditProfile < Base
    set_url '/people{/slug}/edit'
    set_url_matcher(%r{people\/([\w\-]+)\/edit})

    section :form, Sections::ProfileForm, '.edit_person'
  end
end
