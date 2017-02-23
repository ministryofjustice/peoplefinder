module Pages
  class Base < SitePrism::Page
    element :flash_message, '#flash-messages'
    element :admin_link, '.login-bar span.admin-link'
  end
end
