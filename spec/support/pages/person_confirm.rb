require_relative 'sections/person_confirm_form'
require_relative 'sections/person_confirm_search_results'

module Pages
  class PersonConfirm < Base
    set_url_matcher(%r{[tokens/.*|/auth/gplus]})

    section :person_confirm_results, Sections::PersonConfirmSearchResults, '#confirm-person-results'
    section :form, Sections::PersonConfirmForm, '.new_person'
  end
end
