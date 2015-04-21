require 'forwardable'

class PersonUpdater
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person

  def initialize(person, current_user)
    if person.new_record?
      fail NewRecordError, 'cannot update a new Person record'
    end
    @person = person
    @current_user = current_user
  end

  def update!
    person.save!
    person.send_update_email! @current_user
  end
end
