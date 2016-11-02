module Pages
  module Sections
    class GroupForm < SitePrism::Section
      element :group_name, '#group_name'
      element :group_acronym, '#group_acronym'
      element :group_description, '#group_description'
    end
  end
end
