class EmailAddress < Mail::Address
  VALID_EMAIL_PATTERN = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  def initialize(string)
    return false unless string =~ VALID_EMAIL_PATTERN
    super
  end

  def valid_domain?
    Rails.configuration.valid_login_domains.include?(domain)
  end

  def valid_address?
    address ? (address.match(VALID_EMAIL_PATTERN) && valid_domain?) : false
  end
end
