require 'peoplefinder'

class Peoplefinder::EmailAddress
  def initialize(string, valid_login_domains = nil)
    @raw_address = string.to_s
    @valid_login_domains = valid_login_domains || default_valid_login_domains
    begin
      @mail_address = Mail::Address.new(string.to_s)
    rescue Mail::Field::ParseError
      @parse_error = true
    end
  end

  def valid_domain?
    valid_login_domains.any? do |pattern|
      domain_matches_pattern?(pattern, @mail_address.domain)
    end
  end

  def valid_format?
    return false if @parse_error
    return false unless @mail_address.domain && @mail_address.address == @raw_address
    return false unless @mail_address.domain.match(/^\S+$/)
    domain_dot_elements = @mail_address.domain.split(/\./)
    return false unless domain_dot_elements.size > 1 && domain_dot_elements.all?(&:present?)

    true
  end

  def valid_address?
    valid_format? && valid_domain?
  end

  def inferred_last_name
    capitalise(@mail_address.local.split('.')[(multipart_local? ? 1 : 0)])
  end

  def inferred_first_name
    capitalise(@mail_address.local.split('.')[0]) if multipart_local?
  end

  def multipart_local?
    @mail_address.local.split('.').length > 1
  end

  def to_s
    @raw_address
  end

private

  attr_reader :valid_login_domains

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
