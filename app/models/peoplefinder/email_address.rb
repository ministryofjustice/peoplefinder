require 'peoplefinder'
require 'forwardable'

class Peoplefinder::EmailAddress
  extend Forwardable
  def_delegators :@mail_address, :domain, :address, :local, :to_s

  def initialize(string, valid_login_domains = nil)
    @raw_address = string
    @valid_login_domains = valid_login_domains || default_valid_login_domains
    @mail_address = Mail::Address.new(string)
  rescue Mail::Field::ParseError
    @parse_error = true
  end

  def valid_domain?
    valid_login_domains.any? do |pattern|
      domain_matches_pattern?(pattern, domain)
    end
  end

  def valid_format?
    return false if @parse_error
    return false unless domain && address == @raw_address
    return false unless domain.match(/^\S+$/)
    domain_dot_elements = domain.split(/\./)
    return false unless domain_dot_elements.size > 1 && domain_dot_elements.all?(&:present?)

    true
  end

  def valid_address?
    valid_format? && valid_domain?
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
