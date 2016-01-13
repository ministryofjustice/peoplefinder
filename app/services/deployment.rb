class Deployment
  def self.info
    Deployment.new.info
  end

  def initialize(env = ENV)
    @env = env
  end

  def info
    {
      version_number: version_number,
      build_date: build_date,
      commit_id: commit_id,
      build_tag: build_tag
    }
  end

  private

  def version_number
    lookup('APPVERSION')
  end

  def build_date
    lookup('APP_BUILD_DATE')
  end

  def commit_id
    lookup('APP_GIT_COMMIT')
  end

  def build_tag
    lookup('APP_BUILD_TAG')
  end

  def lookup(key)
    @env.fetch(key, 'unknown')
  end
end
