# put gem extensions/monkey patches in lib/ext and this will autoload then
#
Dir[Rails.root.join('lib', 'ext', '*.rb')].each { |file| require file }
