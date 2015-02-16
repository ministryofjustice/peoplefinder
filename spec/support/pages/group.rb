require_relative 'sections/audit'

module Pages
  class Group < SitePrism::Page
    set_url '/teams{/slug}'
    section :audit, Sections::Audit, '.audit'
  end
end
