require 'securerandom'
class Identity < ActiveRecord::Base
  belongs_to :user
  attr_reader :password
  attr_accessor :password_confirmation

  validates :username, presence: true, uniqueness: true
  validates :password, confirmation: true
  validates :password, presence: true, on: :create
  validates :password,
    length: { minimum: 8 },
    if: ->(u) { u.password.present? }

  after_save :clear_password

  def self.authenticate(username, password)
    identity = where(username: username).first
    if identity && identity.valid_password?(password)
      identity.user
    else
      nil
    end
  end

  def password=(pw)
    return if pw.blank?
    @password = pw
    self.password_digest = SCrypt::Password.create(pw)
  end

  def valid_password?(pw)
    SCrypt::Password.new(password_digest) == pw
  end

  def initiate_password_reset!
    self.password_reset_expires_at = 2.hours.from_now
    self.password_reset_token = SecureRandom.hex(32)
    save
  end

private

  def clear_password
    @password = nil
    @password_confirmation = nil
  end
end
