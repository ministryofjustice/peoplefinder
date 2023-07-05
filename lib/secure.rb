class Secure
  def self.compare(aaa, bbb)
    return false if aaa.blank? || bbb.blank? || aaa.bytesize != bbb.bytesize

    l = aaa.unpack "C#{aaa.bytesize}"

    res = 0
    bbb.each_byte { |byte| res |= byte ^ l.shift }
    res.zero?
  end
end
