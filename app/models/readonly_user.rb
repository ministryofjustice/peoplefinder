class ReadonlyUser

  class ActionDispatch::Request
    def readonly_ip_whitelist
      @whitelist ||= IpAddressMatcher.new(Rails.configuration.readonly_ip_whitelist)
    end

    def remote_ip_whitelisted?
      readonly_ip_whitelist === remote_ip
    end
  end

  def self.from_request(request)
    if request.remote_ip_whitelisted?
      new
    end
  end

  def id
    :readonly
  end

  def super_admin?
    false
  end

end
