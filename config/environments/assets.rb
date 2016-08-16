Rails.application.configure do
$stdout.puts "CALLING stdout from environment/assets.rb"
STDOUT.sync = true

  config.eager_load = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0.6'

  config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

  # add any peoplefinder subdirectories to assets pipeline
  Dir.glob("#{Rails.root}/app/assets/**/").each do |path|
    config.assets.paths << path if path =~ /peoplefinder/
  end

end
