module Pages
  class TokenCreated < SitePrism::Page
    set_url_matcher(%r{/tokens$})

    element :info, '.cb-login-email-info'
  end
end
