require 'netaddr'

class IpAddressMatcher

  def initialize(terms)
    @cidrs = cidrs(terms) || []
  end

  def ===(other)
    if Rails.env.development?
      true
    else 
      other = NetAddr::IPv4.parse(other)
      @cidrs.any? { |cidr| cidr.contains(other) }
    end
  end
  alias include? ===

  private

  def cidrs(terms)
    terms.split(';').map { |s| cidr(s) } unless terms.blank?
  end

  def cidr(term)
    NetAddr.parse_net(term)
  end
end
