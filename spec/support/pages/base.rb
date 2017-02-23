module Pages
  class Base < SitePrism::Page
    element :flash_message, '#flash-messages'
    element :manage_link, '.login-bar span.manage-link'
  end
end
