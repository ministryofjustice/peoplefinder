class Token < ActiveRecord::Base
  belongs_to :user
  after_initialize :generate_value

  def object
    user
  end

  def to_param
    value
  end

private

  def generate_value
    self.value ||= SecureRandom.uuid
  end
end
