module Pages
  module Sections
    class SearchFooter < SitePrism::Section
      element :add_them_link, 'a[href="/people/new"]'
    end
  end
end
