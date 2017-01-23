module Query

  class PeopleInGroupsQuery

    class << self
      delegate :call, to: :new
    end

    def initialize(groups, relation = Person.all)
      @groups = groups
      @relation = relation
    end

    def call
      Person.from(@relation.joins(:memberships).
            where(memberships: { group_id: @groups }).
            select("people.*,
                  string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names"
                  ).
            group(:id).
            uniq, :people)
    end
  end
end
