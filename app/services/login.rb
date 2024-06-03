class Login
  SESSION_KEY = "current_user_id".freeze

  def initialize(session, person)
    @session = session
    @person = person
  end

  def login
    if @person.is_a?(Person)
      @person.login_count += 1
      @person.last_login_at = Time.zone.now
      @person.save # rubocop:disable Rails/SaveBang
    end

    @session[SESSION_KEY] = @person.id
  end

  def logout
    @session.delete(SESSION_KEY)
  end

  def self.current_user(session)
    if @person.is_a?(Person)
      Person.find(session[SESSION_KEY]) if session[SESSION_KEY].present?
    else
      ExternalUser.find(session[SESSION_KEY]) if session[SESSION_KEY].present?
    end
  end
end
