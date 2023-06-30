require "forwardable"

class PersonDestroyer
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person

  def initialize(person, current_user)
    if person.new_record?
      raise NewRecordError, "cannot destroy a new Person record"
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
    if @person.notify_of_change?(@current_user)
      UserUpdateMailer.deleted_profile_email(
        @person.email, @person.given_name, @current_user.email
      ).deliver_later
    end
  end
end
