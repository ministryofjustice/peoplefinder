require 'forwardable'
require 'yaml'
require 'user_agent'

class AuditVersionPresenter
  extend Forwardable
  def_delegators :@version, :event, :whodunnit, :created_at, :ip_address,
    :user_agent

  def initialize(version)
    @version = version
  end

  def changes
    YAML.load(@version.object_changes).map do |field, (_, new)|
      "#{field} => #{new}"
    end
  end

  def user_agent_summary
    return nil if user_agent.blank?
    ua = UserAgent.parse(user_agent)
    '%s %s' % [ua.browser, ua.version]
  end

  def self.wrap(versions)
    Array(versions).map do |version|
      AuditVersionPresenter.new(version)
    end
  end
end
