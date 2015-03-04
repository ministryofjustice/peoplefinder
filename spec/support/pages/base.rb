module Pages
  class Base < SitePrism::Page
    element :super_admin_badge, '.login-bar span.super-admin'
  end
end
