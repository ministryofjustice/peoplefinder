require 'singleton'

class Home
  include Singleton
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def persisted?
    true
  end

  def to_s
    'Home'
  end

  alias_method :short_name, :to_s

  def self.path
    [instance]
  end
end
