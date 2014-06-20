class Person < ActiveRecord::Base
  validates_presence_of :surname
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  def name
    [given_name, surname].compact.join(' ').strip
  end

  def to_s
    name
  end
end
