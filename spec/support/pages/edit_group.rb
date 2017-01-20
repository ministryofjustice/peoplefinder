require_relative 'sections/group_form'

module Pages
  class EditGroup < Base
    set_url '/teams{/slug}/edit'
    set_url_matcher(%r{teams\/([\w\-]+)\/edit})

    section :form, Sections::GroupForm, '.edit_group'
  end
end
