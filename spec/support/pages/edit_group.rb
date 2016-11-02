require_relative 'sections/group_form'

module Pages
  class EditGroup < SitePrism::Page
    set_url '/teams{/slug}/edit'
    set_url_matcher(%r{teams\/([a-zA-Z\-]+)\/edit})

    section :form, Sections::GroupForm, '.edit_group'
  end
end
