module Pages
  class Base < SitePrism::Page
    element :flash_message, '#flash-messages'
    element :manage_link, '#proposition-links .manage-link'
  end
end
