require 'mail'

class EmailExtractor
  def extract(source)
    return nil unless source
    candidates = [:full, :angled, :parenthesized].flat_map { |method|
      send(method, source)
    }.map(&:strip)
    candidates.find { |c| valid?(c) } || source
  end

private

  def full(str)
    str
  end

  def angled(str)
    str.scan(/<([^>]+)>/).map(&:first)
  end

  def parenthesized(str)
    str.scan(/\(([^\)]+)\)/).map(&:first)
  end

  def valid?(addr)
    return false unless addr
    mail_address = Mail::Address.new(addr)
    mail_address.domain && addr == mail_address.address
  rescue Mail::Field::ParseError
    false
  end
end
