# Do the gov-static, moj-base even exist?? docker output indicates not
Rails.application.config.assets.precompile += %w[
  email.css
  Jcrop/css/jquery.Jcrop.min.css
  Jcrop/js/jquery.Jcrop.min.js
  application-ie6.css
  application-ie7.css
  application-ie8.css
]

Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")
