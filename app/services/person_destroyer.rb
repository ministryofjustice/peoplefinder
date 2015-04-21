require 'forwardable'

class PersonDestroyer
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person

  def initialize(person, current_user)
    if person.new_record?
      fail NewRecordError, 'cannot destroy a new Person record'
    end
    @person = person
    @current_user = current_user
  end

  def destroy!
    send_destroy_email!
    person.destroy!
  end

private

  def send_destroy_email!
    if @person.should_send_email_notification?(@current_user)
      UserUpdateMailer.deleted_profile_email(
        @person, @current_user.email
      ).deliver_later
    end
  end
end
