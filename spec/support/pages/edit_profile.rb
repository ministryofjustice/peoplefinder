require_relative 'sections/error_summary'
require_relative 'sections/profile_form'

module Pages
  class EditProfile < Base
    set_url '/people{/slug}/edit'
    set_url_matcher(%r{people\/([\w\-]+)\/edit})

    section :error_summary, Sections::ErrorSummary, '.error-summary'
    section :form, Sections::ProfileForm, '.edit_person'
  end
end
