class Login
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :username, :password
  attr_reader :user

  def initialize(opts = {})
    @username = opts[:username]
    @password = opts[:password]
  end

  def save
    @user = Identity.authenticate(username, password)
    @user ? true : false
  end

  def persisted?
    false
  end
end
