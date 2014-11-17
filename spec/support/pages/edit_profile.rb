module Pages
  class EditProfile < SitePrism::Page
    set_url_matcher /people\/([a-zA-Z\-]+)/
  end
end