# Do the gov-static, moj-base even exist?? docker output indicates not
Rails.application.config.assets.precompile += %w(
  gov-static/gov-goodbrowsers.css
  gov-static/gov-ie6.css
  gov-static/gov-ie7.css
  gov-static/gov-ie8.css
  gov-static/gov-fonts.css
  gov-static/gov-fonts-ie8.css
  gov-static/gov-print.css
  moj-base.css
  peoplefinder/peoplefinder-lt-ie9.css
  peoplefinder/peoplefinder-ie7.css
  gov-static/gov-ie.js
  Jcrop/css/jquery.Jcrop.min.css
  Jcrop/css/jquery.Jcrop.min.js
)

unless Rails.env.production?
  Rails.application.config.assets.precompile += %w( teaspoon.css
                                                    teaspoon-teaspoon.js
                                                    mocha/1.17.1.js
                                                    teaspoon-mocha.js )
end
