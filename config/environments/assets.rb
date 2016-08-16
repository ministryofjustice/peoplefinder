STDOUT.sync = true
$stdout.puts "CALLING stdout from environment/assets.rb"
Rails.application.configure do
  config.eager_load = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0.6'

  # config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

  # add any peoplefinder subdirectories to assets pipeline
  # Dir.glob("#{Rails.root}/app/assets/**/").each do |path|
  #   config.assets.paths << path if path =~ /peoplefinder/
  # end

  # Rails.application.config.assets.precompile += %w(
  #   gov-static/gov-goodbrowsers.css
  #   gov-static/gov-ie6.css
  #   gov-static/gov-ie7.css
  #   gov-static/gov-ie8.css
  #   gov-static/gov-fonts.css
  #   gov-static/gov-fonts-ie8.css
  #   gov-static/gov-print.css
  #   moj-base.css
  #   peoplefinder/peoplefinder-lt-ie9.css
  #   peoplefinder/peoplefinder-ie7.css
  #   gov-static/gov-ie.js
  #   Jcrop/css/jquery.Jcrop.min.css
  #   Jcrop/css/jquery.Jcrop.min.js
  # )

end
