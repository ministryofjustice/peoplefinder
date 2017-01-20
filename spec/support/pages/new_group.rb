require_relative 'sections/group_form'

module Pages
  class NewGroup < Base
    set_url '/teams/new'
    set_url_matcher(/teams\/new/)

    section :form, Sections::GroupForm, '.new_group'
  end
end
