require 'forwardable'

class PersonUpdater
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person, :changes, :membership_changes

  def initialize(person, current_user)
    if person.new_record?
      raise NewRecordError, 'cannot update a new Person record'
    end
    @person = person
    @current_user = current_user
    store_changes
  end

  def update!
    person.save!
    send_update_email!
  end

  private

  def store_changes
    set_person_changes
    set_membership_changes
  end

  def set_person_changes
    @changes = PersonChangesPresenter.new(@person.changes)
  end

  def set_membership_changes
    @membership_changes = MembershipChangesPresenter.new(@person.membership_changes)
  end

  def send_update_email!
    if person.notify_of_change?(@current_user)
      UserUpdateMailer.updated_profile_email(
        person, changes.serialize, membership_changes.serialize, @current_user.email
      ).deliver_later
    end
  end
end
