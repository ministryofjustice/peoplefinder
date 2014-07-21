class User < OmniAuth::Identity::Models::ActiveRecord
  before_validation :set_password_if_required

  validate :validate_email_domain
  validate :email, presence: true, unique: true

  def self.for_email(email)
    where(email: email).first_or_create
  end

  def self.from_auth_hash(auth_hash)
    email = normalize_email(auth_hash['info']['email'])

    user = User.for_email(email)
    return nil unless user.valid?
    user
  end

  def self.normalize_email(e)
    Mail::Address.new(e).address.downcase
  end

  def to_s
    name || email
  end

  def email=(e)
    super User.normalize_email(e)
  end

  def domain
    Mail::Address.new(email).domain
  end

  def set_password_reset_token!
    self.password_reset_token = SecureRandom.urlsafe_base64
    save!
    self.password_reset_token
  end

  def start_password_reset_flow!
    set_password_reset_token!
    UserMailer.password_reset_notification(self).deliver
  end

  def update_password!(password, confirmation)
    self.password = password
    self.password_confirmation = confirmation
    save!
  end



private

  def validate_email_domain
    valid_domains = Rails.configuration.valid_login_domains
    unless valid_domains.include?(domain)
      errors.add :email, "must be in the list of permitted domains"
    end
  end

  def set_password_if_required
    if self.password.blank? && self.password_digest.blank?
      temp_password = SecureRandom.hex
      self.password = temp_password
      self.password_confirmation = temp_password
    end
  end
end
