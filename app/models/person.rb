class Person < ActiveRecord::Base
  validates_presence_of :surname

  def name
    [given_name, surname].compact.join(' ')
  end
end
