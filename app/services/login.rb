class Login
  SESSION_KEY = "current_user_id".freeze
  KEY_TYPE = "user_type".freeze

  def initialize(session, person)
    @session = session
    @person = person
  end

  def login
    if @person.is_a?(Person)
      @session[KEY_TYPE] = "person"
      @person.login_count += 1
      @person.last_login_at = Time.zone.now
      @person.save # rubocop:disable Rails/SaveBang
    else
      @session[KEY_TYPE] = "external_user"
    end
    @session[SESSION_KEY] = @person.id
  end

  def logout
    @session.delete(SESSION_KEY)
  end

  def self.current_user(session)
    if session[SESSION_KEY].present?
      if session[KEY_TYPE] == "person"
        Person.find(session[SESSION_KEY])
      elsif ExternalUser.find(session[SESSION_KEY])
        ReadonlyUser.new
      end
    end
  end
end
