class Community < ActiveRecord::Base
  has_many :people, dependent: :restrict_with_exception

  def to_s
    name
  end
end
