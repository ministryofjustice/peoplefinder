class PeopleInGroupsQuery < BaseQuery

  def initialize(groups, relation = Person.all)
    @groups = groups
    @relation = relation.ordered_by_name
  end

  def call
    Person.from(@relation.joins(:memberships).
          where(memberships: { group_id: @groups }).
          select("people.*,
                string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names"
                ).
          group(:id).
          distinct, :people).ordered_by_name
  end
end
