class PeopleUpdatedOlderThanQuery < BaseQuery
  def initialize(within, relation = Person.all) # rubocop:disable Lint/MissingSuper
    @relation = relation.ordered_by_name
    @within = within
  end

  def call
    @relation.where("updated_at < ?", @within)
  end
end
