class BaseQuery

  class << self
    delegate :call, to: :new
  end

  def initialize(relation = Person.all)
    @relation = relation
  end

  def call
    raise '#call should be implemented in a sub class of BaseQuery'
  end
end
