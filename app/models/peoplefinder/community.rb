require 'peoplefinder'

class Peoplefinder::Community < ActiveRecord::Base
  self.table_name = 'communities'

  has_many :people, dependent: :restrict_with_exception

  def to_s
    name
  end
end
