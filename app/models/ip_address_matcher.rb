require 'netaddr'

class IpAddressMatcher

  def initialize(terms)
    @cidrs = cidrs(terms) || []
  end

  def ===(other)
    @cidrs.any? { |cidr| cidr.matches?(other) }
  end
  alias include? ===

  private

  def cidrs(terms)
    terms.split(';').map { |s| cidr(s) } unless terms.blank?
  end

  def cidr(term)
    NetAddr::CIDR.create(term)
  end
end
