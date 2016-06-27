class RailsHost

  VALID_ENVS = %w( dev staging production ).freeze

  def self.env
    ENV['ENV']
  end

  def self.method_missing(method)
    env_name = method.to_s.sub(/\?$/, '')
    if VALID_ENVS.include?(env_name)
      env == env_name
    else
      super
    end
  end

end
