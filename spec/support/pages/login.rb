module Pages
  class Login < SitePrism::Page
    set_url_matcher(%r{/sessions/new$})
  end
end
