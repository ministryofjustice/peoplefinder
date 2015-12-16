require 'forwardable'

class EmailAddress
  extend Forwardable
  def_delegators :@mail_address, :domain, :address, :local, :to_s

  def initialize(string)
    @raw_address = string
    @valid_login_domains = default_valid_login_domains
    @mail_address = Mail::Address.new(string)
    @parsed_ok = true
  rescue Mail::Field::ParseError
    @parsed_ok = false
  end

  def valid_domain?
    valid_login_domains.any? { |pattern| pattern === domain }
  end

  def valid_format?
    @parsed_ok && canonical_address? && globally_addressable_domain?
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

  def canonical_address?
    address == @raw_address
  end

  def globally_addressable_domain?
    domain && domain.match(/
      \A           # beginning of string
      (?:          # one or more of:
        [0-9a-z-]+ #   domain part (can include digits and hyphens)
        \.         #   dot
      )+           #
      [a-z]+       # top-level domain (no digits or hyphens)
      \z           # end of string
    /xi)
  end

  def default_valid_login_domains
    PermittedDomain.pluck(:domain)
  end

  def capitalise(word)
    word.downcase.to_s.gsub(/\b('?\S)/u) do
      (Regexp.last_match[1]).upcase
    end
  end
end
