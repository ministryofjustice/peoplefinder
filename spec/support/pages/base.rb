module Pages
  class Base < SitePrism::Page
    element :flash_message, '#flash-messages'
    element :super_admin_badge, '.login-bar span.super-admin'
  end
end
