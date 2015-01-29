module Pages
  class Base < SitePrism::Page
    element :super_admin_badge, '#log-in-out span.super-admin'
  end
end
