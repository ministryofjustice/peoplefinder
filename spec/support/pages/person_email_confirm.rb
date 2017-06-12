require_relative 'sections/person_email_confirm_form'

module Pages
  class PersonEmailConfirm < Base
    set_url_matcher(%r{people\/.*\/email\/edit})

    element :info, '.cb-email-update-info'
    section :form, Sections::PersonEmailConfirmForm, '.edit_person'
  end
end
