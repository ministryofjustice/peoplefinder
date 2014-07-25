class ResponsibilitiesAgreement < SimpleDelegator
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  class <<self
    extend Forwardable
    def_delegator :Agreement, :reflect_on_association
  end
end
