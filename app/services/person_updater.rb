require 'forwardable'

class PersonUpdater
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person, :changes

  def initialize(person, current_user)
    if person.new_record?
      raise NewRecordError, 'cannot update a new Person record'
    end
    @person = person
    @current_user = current_user
  end

  def update!
    person.save!
    store_changes person
    send_update_email!
  end

  private

  def store_changes person
    @changes = PersonAllChangesPresenter.new(person.all_changes)
  end

  def send_update_email!
    if person.notify_of_change?(@current_user)
      UserUpdateMailer.updated_profile_email(
        person, changes.serialize, @current_user.email
      ).deliver_later
    end
  end
end
