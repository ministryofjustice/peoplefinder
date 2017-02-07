require 'forwardable'

class PersonUpdater
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person, :changes

  def initialize(person:, current_user:, state_cookie:)
    if person.new_record?
      raise NewRecordError, 'cannot update a new Person record'
    end
    @person = person
    @current_user = current_user
    @state_cookie = state_cookie
  end

  def update!
    person.save!
    present person unless @state_cookie.create?
    send_update_email!
  end

  def flash_message
    :profile_updated
  end

  private

  def present person
    @changes = ProfileChangesPresenter.new(person.all_changes)
  end

  def send_update_email!
    if @state_cookie.save_profile? && person.notify_of_change?(@current_user)
      if @state_cookie.create?
        UserUpdateMailer.new_profile_email(@person, @current_user.try(:email)).deliver_later
      else
        UserUpdateMailer.updated_profile_email(@person, changes.serialize, @current_user.try(:email)).deliver_later
      end
    end
  end
end
