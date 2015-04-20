class ProfilePhoto < ActiveRecord::Base
  has_one :person
end
