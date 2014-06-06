class AllocationResponse
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :response_action, :reason_option, :reason

  validates_presence_of :response_action
  validates :reason_option, presence: true, if: :rejected?
  validates :reason, presence: true, if: :rejected?


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def rejected?
    response_action == 'reject'
  end

end