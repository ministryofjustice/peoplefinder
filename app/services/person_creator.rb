require 'forwardable'

class PersonCreator
  extend Forwardable

  def_delegators :person, :valid?

  attr_reader :person
  def initialize(person:, current_user:, state_cookie:)
    @person = person
    @current_user = current_user
    @state_cookie = state_cookie
  end

  def create!
    person.save!
    default_membership!(person) if person.memberships.empty?
    send_create_email!
  end

  def flash_message
    :profile_created
  end

  private

  def default_membership! person
    person.memberships.create!(group: Group.department) if Group.department.present?
  end

  def send_create_email!
    if @state_cookie.save_profile?
      if person.notify_of_change?(@current_user)
        UserUpdateMailer.new_profile_email(
          @person, @current_user.try(:email)
        ).deliver_later
      end
    end
  end
end
