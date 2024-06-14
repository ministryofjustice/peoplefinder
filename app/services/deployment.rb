class Deployment
  def self.info
    Deployment.new.info
  end

  def initialize(env = ENV)
    @env = env
  end

  def info
    {
      build_date:,
      commit_id:,
      build_tag:,
    }
  end

private

  def build_date
    lookup("APP_BUILD_DATE")
  end

  def commit_id
    lookup("APP_GIT_COMMIT")
  end

  def build_tag
    lookup("APP_BUILD_TAG")
  end

  def lookup(key)
    @env.fetch(key, "unknown")
  end
end
