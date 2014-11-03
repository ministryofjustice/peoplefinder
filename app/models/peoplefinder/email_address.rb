require 'peoplefinder'

class Peoplefinder::EmailAddress < Mail::Address
  VALID_EMAIL_PATTERN = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  def initialize(string)
    return false unless string =~ VALID_EMAIL_PATTERN
    super
  end

  def valid_domain?
    valid_login_domains.select do |valid_login_domain|
      domain.match valid_login_domain
    end.present?
  end

  def valid_format?
    address && address.match(VALID_EMAIL_PATTERN)
  end

  def valid_address?
    address ? (valid_format? && valid_domain?) : false
  end

  def inferred_last_name
    capitalise(local.split('.')[(multipart_local? ? 1 : 0)])
  end

  def inferred_first_name
    capitalise(local.split('.')[0]) if multipart_local?
  end

  def multipart_local?
    local.split('.').length > 1
  end

private

  def valid_login_domains
    Rails.configuration.try(:valid_login_domains) || []
  end

  def capitalise(word)
    word.downcase.to_s.gsub(/\b('?\S)/u) do
      (Regexp.last_match[1]).upcase
    end
  end
end
