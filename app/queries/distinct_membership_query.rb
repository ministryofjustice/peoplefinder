class DistinctMembershipQuery < BaseQuery

  def initialize(group:, leadership:)
    @group = group
    @leadership = leadership
  end

  def call
    Person.joins(:memberships).
      where(memberships: { group_id: @group.id, leader: @leadership }).
      select("people.*, string_agg(CASE role WHEN '' THEN NULL ELSE role END, ', ' ORDER BY role) AS role_names").
      from('people').
      group('people.id, people.given_name, people.surname, people.slug').
      distinct
  end
end
