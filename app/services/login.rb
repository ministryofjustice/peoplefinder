class Login
  SESSION_KEY = "current_user_id".freeze
  TYPE_KEY = "user_type".freeze

  def initialize(session, person)
    @session = session
    @person = person
  end

  def login
    @session[TYPE_KEY] = nil

    case @person
    when Person
      @session[TYPE_KEY] = "person"
      @person.login_count += 1
      @person.last_login_at = Time.zone.now
      @person.save # rubocop:disable Rails/SaveBang
    when ExternalUser
      @session[TYPE_KEY] = "external_user"
    else
      return
    end

    @session[SESSION_KEY] = @person.id
  end

  def logout
    @session.delete(SESSION_KEY)
  end

  def self.current_user(session)
    if session[SESSION_KEY].present?
      if session[TYPE_KEY] == "person"
        Person.find(session[SESSION_KEY])
      elsif ExternalUser.find(session[SESSION_KEY])
        ReadonlyUser.new
      end
    end
  end
end
