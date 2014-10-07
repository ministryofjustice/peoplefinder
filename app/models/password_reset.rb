class PasswordReset
  include ActiveModel::Validations

  validate :admin_user_with_email_must_exist

  attr_accessor :email

  def initialize(opts = {})
    @email = opts[:email]
  end
  
  def save
    valid?
  end

  private
  def admin_user_with_email_must_exist
    errors.add(:base, 'No admin user with that email exists') unless load_user
  end

  def load_user
    User.with_identity.admin.where(email: @email).first
  end
end
