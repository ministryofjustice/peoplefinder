class ReadonlyUser
  def self.from_request(request)
    header_name = "HTTP_#{Rails.configuration.readonly[:header].gsub('-', '_')}"
    header_value = Rails.configuration.readonly[:value]

    if request.headers[header_name] && request.headers[header_name] == header_value
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
