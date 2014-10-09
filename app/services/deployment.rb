module Deployment
  def info
    { version_number: version_number, build_date: build_date, commit_id: commit_id, build_tag: build_tag }
  end

  def version_number
    ENV['APPVERSION'] || 'unknown'
  end

  def build_date
    ENV['APP_BUILD_DATE'] || 'unknown'
  end

  def commit_id
    ENV['APP_GIT_COMMIT'] || 'unknown'
  end

  def build_tag
    ENV['APP_BUILD_TAG'] || 'unknown'
  end

  extend self
end
