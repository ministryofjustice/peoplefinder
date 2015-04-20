require 'forwardable'

class PersonCreator
  extend Forwardable

  def_delegators :person, :valid?

  attr_reader :person

  def initialize(person, current_user)
    @person = person
    @current_user = current_user
  end

  def create!
    person.save!
    person.send_create_email! @current_user
  end
end
