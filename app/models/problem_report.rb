require 'virtus'
require 'active_model'

class ProblemReport
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attribute :goal, String
  attribute :problem, String
  attribute :ip_address, String
  attribute :person_email, String
  attribute :person_id, Integer
  attribute :browser, String
  attribute :timestamp, Integer

  def initialize(*)
    super
    self.timestamp ||= Time.now.to_i
  end

  def persisted?
    false
  end

  def reported_at
    Time.at(timestamp).utc
  end
end
