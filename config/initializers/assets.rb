# Do the gov-static, moj-base even exist?? docker output indicates not
Rails.application.config.assets.precompile += %w[
  email.css
  jquery-jcrop/css/jquery.Jcrop.min.css
  jquery-jcrop/js/jquery.Jcrop.min.js
  application-ie6.css
  application-ie7.css
  application-ie8.css
]
