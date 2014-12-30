class Token < ActiveRecord::Base
  belongs_to :user
  belongs_to :review
  after_initialize :generate_value

  def object
    user
  end

  def to_param
    value
  end

  def expired?
    created_at < Time.now - Rails.application.config.token_timeout
  end

private

  def generate_value
    self.value ||= SecureRandom.urlsafe_base64(16)
  end
end
