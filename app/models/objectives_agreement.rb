class ObjectivesAgreement < SimpleDelegator
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  extend  SingleForwardable

  def_single_delegator :Agreement, :reflect_on_association
end
