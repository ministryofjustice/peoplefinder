module Pages
  class TokenCreated < SitePrism::Page
    set_url_matcher(%r{/tokens$})

    element :info, '.login-email-info'
  end
end
