require_relative 'sections/audit'

module Pages
  class Profile < Base
    set_url '/people{/slug}'
    section :audit, Sections::Audit, '.audit'
  end
end
