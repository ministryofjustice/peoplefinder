module Peoplefinder
  class PermittedDomain < ActiveRecord::Base
    self.table_name = 'permitted_domains'
    validates :domain, presence: true
  end
end
