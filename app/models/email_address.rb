class EmailAddress < Mail::Address
  VALID_EMAIL_PATTERN = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  def initialize(string)
    return false unless string =~ VALID_EMAIL_PATTERN
    super
  end

  def valid_domain?
    Rails.configuration.valid_login_domains.include?(domain)
  end

  def valid_format?
    address && address.match(VALID_EMAIL_PATTERN)
  end

  def valid_address?
    address ? (valid_format? && valid_domain?) : false
  end

  def inferred_last_name
    if multipart_local?
      local.split('.')[1]
    else
      local.split('.')[0]
    end
  end

  def inferred_first_name
    local.split('.')[0] if multipart_local?
  end

  def multipart_local?
    local.split('.').length > 1
  end
end
