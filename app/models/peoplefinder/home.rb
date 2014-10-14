require 'singleton'
require 'peoplefinder'

class Peoplefinder::Home
  include Singleton
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def to_s
    'Home'
  end

  def self.path
    [instance]
  end
end
