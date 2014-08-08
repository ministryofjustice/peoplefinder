require 'singleton'

class Home
  include Singleton
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def to_s
    'Home'
  end

  def self.hierarchy
    [instance]
  end
end
