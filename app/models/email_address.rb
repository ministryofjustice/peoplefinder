class EmailAddress < Mail::Address
  def valid_domain?
    Rails.configuration.valid_login_domains.include?(domain)
  end
end
