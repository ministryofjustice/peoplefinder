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
    lookup("BUILD_DATE")
  end

  def commit_id
    lookup("COMMIT_ID")
  end

  def build_tag
    lookup("BUILD_TAG")
  end

  def lookup(key)
    @env.fetch(key, "unknown")
  end
end
