class Login
  SESSION_KEY = "current_user_id".freeze

  def initialize(session, person)
    @session = session
    @person = person
  end

  def login
    @person.login_count += 1
    @person.last_login_at = Time.zone.now
    @person.save # rubocop:disable Rails/SaveBang

    @session[SESSION_KEY] = @person.id
  end

  def logout
    @session.delete(SESSION_KEY)
  end

  def self.current_user(session)
    Person.find(session[SESSION_KEY]) if session[SESSION_KEY].present?
  end
end
