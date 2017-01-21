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
    default_membership!(person) if person.memberships.empty?
    send_create_email!
  end

  private

  def default_membership! person
    person.memberships.create!(group: Group.department) if Group.department.present?
  end

  def send_create_email!
    if person.notify_of_change?(@current_user)
      UserUpdateMailer.new_profile_email(
        @person, @current_user.try(:email)
      ).deliver_later
    end
  end
end
