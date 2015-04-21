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
    send_create_email!
  end

private

  def send_create_email!
    if person.notify_of_change?(@current_user)
      UserUpdateMailer.new_profile_email(
        @person, @current_user.try(:email)
      ).deliver_later
    end
  end
end
