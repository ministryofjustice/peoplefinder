Dir[File.expand_path(Rails.root.join('lib','geckoboard_publisher','**','*.rb'), __FILE__)].each do |f| 
  require f
end
