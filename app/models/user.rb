class User < ActiveRecord::Base
  def self.from_auth_hash(auth_hash)
    email = auth_hash['info']['email']
    name = auth_hash['info']['name']
    domain = email.split(/@/, 2)[1]
    valid_domains = Rails.configuration.valid_login_domains

    return nil unless valid_domains.include?(domain)

    User.where(email: email).first_or_create.tap { |user|
      user.update_attribute(:name, name) unless user.name == name
    }
  end

  def to_s
    name || email
  end
end
