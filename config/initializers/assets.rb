# Do the gov-static, moj-base even exist?? docker output indicates not
Rails.application.config.assets.precompile += %w(
  email.css
  Jcrop/css/jquery.Jcrop.min.css
  Jcrop/js/jquery.Jcrop.min.js
  application-ie6.css
  application-ie7.css
  application-ie8.css
)
# TODO: these were in the precompile array
#       but look to be a leftover from
#       old templates used. Remove once
#       confident not required (they are
#       not being compiled in any event)
# gov-static/gov-goodbrowsers.css
# gov-static/gov-ie6.css
# gov-static/gov-ie7.css
# gov-static/gov-ie8.css
# gov-static/gov-fonts.css
# gov-static/gov-fonts-ie8.css
# gov-static/gov-print.css
# moj-base.css
# gov-static/gov-ie.js

unless Rails.env.production?
  Rails.application.config.assets.precompile += %w( teaspoon.css
                                                    teaspoon-teaspoon.js
                                                    mocha/1.17.1.js
                                                    teaspoon-mocha.js )
end
