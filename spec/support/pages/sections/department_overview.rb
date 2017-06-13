module Pages
  module Sections
    class DepartmentOverview < SitePrism::Section
      element :department_name, '.mod-heading'
      element :leader_profile_image, 'img.media-object'
    end
  end
end
