class ReadonlyUser
  def self.from_request(request)
    header_name = "HTTP_#{Rails.configuration.readonly[:header].tr('-', '_')}"
    header_value = Rails.configuration.readonly[:value]
    Rails.logger.ap "File: #{File.basename(__FILE__)}, Method: #{__method__}", :warn
    Rails.logger.ap "header name and value : #{header_name} #{header_value}", :warn
    
    request.headers.each do |k,v|
      Rails.logger.ap "header,value: #{k} : #{v}", :warn
    end
    Rails.logger.ap "request header: #{request.headers[header_name]}", :warn
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
