require 'forwardable'

class PersonUpdater
  extend Forwardable
  NewRecordError = Class.new(RuntimeError)

  def_delegators :person, :valid?

  attr_reader :person, :current_user, :session_id

  def initialize(person:, current_user:, state_cookie:, session_id: nil)
    if person.new_record?
      raise NewRecordError, 'cannot update a new Person record'
    end
    @person = person
    @current_user = current_user
    @state_cookie = state_cookie
    @session_id = session_id
  end

  def update!
    person.save!
    QueuedNotification.queue!(self) if person.notify_of_change?(@current_user)
  end

  def flash_message
    :profile_updated
  end

  def edit_finalised?
    @state_cookie.save_profile?
  end
end
