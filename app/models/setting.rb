class Setting < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  def self.[]=(k, v)
    find_or_initialize_by(key: k.to_s).set v
  end

  def self.[](k)
    fetch(k, nil)
  end

  def self.fetch(k, *default)
    existing = find_by(key: k.to_s)
    return existing.get if existing
    return default.first if default.length > 0
    raise KeyError, "key not found: #{k.inspect}"
  end

  def to_param
    key
  end

  def set(v)
    update value: v.to_s
  end

  def get
    value
  end
end
