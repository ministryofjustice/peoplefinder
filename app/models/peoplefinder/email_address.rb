require 'peoplefinder'

class Peoplefinder::EmailAddress < Mail::Address

  def initialize(string, valid_login_domains = nil)
    return false unless valid_email_address?(string)
    @valid_login_domains = valid_login_domains || default_valid_login_domains
    super(string)
  end

  def valid_domain?
    valid_login_domains.any? do |pattern|
      domain_matches_pattern?(pattern, domain)
    end
  end

  def valid_format?
    address && valid_email_address?(address)
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

  attr_reader :valid_login_domains

  def valid_email_address?(address)
    begin
      mail = Mail::Address.new(address)
    rescue Mail::Field::ParseError
      return false
    end

    return false unless mail.domain && mail.address == address

    return false unless mail.domain.match(/^\S+$/)
    domain_dot_elements = mail.domain.split(/\./)
    return false unless domain_dot_elements.size > 1 && domain_dot_elements.all?(&:present?)

    true
  end

  def default_valid_login_domains
    Rails.configuration.try(:valid_login_domains) || []
  end

  def capitalise(word)
    word.downcase.to_s.gsub(/\b('?\S)/u) do
      (Regexp.last_match[1]).upcase
    end
  end

  def domain_matches_pattern?(pattern, domain)
    case pattern
    when String
      domain == pattern
    when Regexp
      domain =~ pattern
    end
  end
end
