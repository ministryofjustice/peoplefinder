module Pages
  class Login < SitePrism::Page
    set_url_matcher(%r{/sessions/new$})

    element :description, '.description'

    element :email, '.new_token #token_user_email'
    element :request_button, '.new_token .button'
  end
end
