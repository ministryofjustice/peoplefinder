require_relative 'sections/person_confirm_form'
require_relative 'sections/search_results'

module Pages
  class PersonConfirm < Base
    set_url '/tokens{/token}'
    set_url_matcher(%r{tokens\/.*})

    section :search_results, Sections::SearchResults, '#results'
    section :form, Sections::PersonConfirmForm, '.new_person'
  end
end
