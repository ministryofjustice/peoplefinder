Rails.application.config.assets.paths << Peoplefinder::Engine.root.join(
  'vendor', 'assets', 'components'
  )

Rails.application.config.assets.precompile += %w[
  gov-static/gov-goodbrowsers.css
  gov-static/gov-ie6.css
  gov-static/gov-ie7.css
  gov-static/gov-ie8.css
  gov-static/gov-fonts.css
  gov-static/gov-fonts-ie8.css
  gov-static/gov-print.css
  moj-base.css
  gov-static/gov-ie.js
  jquery.Jcrop.min.css
  jquery.Jcrop.min.js
]

unless Rails.env.production?
  Rails.application.config.assets.precompile += %w[ teaspoon.css
                                                    teaspoon-teaspoon.js
                                                    mocha/1.17.1.js
                                                    teaspoon-mocha.js ]
end

Dir.chdir(Peoplefinder::Engine.root.join('vendor', 'assets', 'components')) do
  Rails.application.config.assets.precompile += Dir['**/*.{js,css}']
end
