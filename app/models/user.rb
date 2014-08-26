class User < ActiveRecord::Base
  has_many :tokens

  def to_s
    [name, email].reject(&:blank?).first
  end
end
