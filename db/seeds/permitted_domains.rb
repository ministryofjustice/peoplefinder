require 'yaml'

data_file = Rails.root.join('db', 'seeds', 'data', 'permitted_domains.yml')
domains   = YAML.load_file(data_file)

domains.each do |domain|
  PermittedDomain.find_or_create_by(domain: domain)
end


