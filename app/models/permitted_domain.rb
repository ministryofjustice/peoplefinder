class PermittedDomain < ActiveRecord::Base
  validates :domain, presence: true
end
