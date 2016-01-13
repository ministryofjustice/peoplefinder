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
    send_update_email!
  end

  private

  def send_update_email!
    if @person.notify_of_change?(@current_user)
      UserUpdateMailer.updated_profile_email(
        @person, @current_user.email
      ).deliver_later
    end
  end
end
