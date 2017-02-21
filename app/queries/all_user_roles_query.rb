class AllUserRolesQuery < BaseQuery

  def initialize
    @relation = Person.all.unscoped
  end

  def call
    @relation.
      joins(joins_sql).
      select(selected_columns).
      order('people.id, full_name')
  end

  def data
    call.map do |rec|
      { id: rec.id,
        full_name: rec.full_name,
        address: rec.address, # can't use location as the name as this is a method on person model
        team_name: rec.team_name,
        ancestors: rec.ancestors,
        team_role: rec.team_role,
        login_count: rec.login_count,
        last_login_at: rec.last_login_at,
        updates_count: rec.updates_count
      }
    end
  end

  private

  def joins_sql
    <<~SQL
    LEFT JOIN memberships ON memberships.person_id = people.id
    LEFT JOIN groups ON groups.id = memberships.group_id
    SQL
  end

  # rubocop:disable MethodLength
  def select_ancestors
    <<~SQL
      CASE
        WHEN groups.ancestry_depth > 0 then
          (
          SELECT array_agg(name) AS names
          FROM
            (
            SELECT g2.name AS name
            FROM groups AS g2
            WHERE g2.id::text = ANY (regexp_split_to_array(groups.ancestry,'\/'))
            ) as group_names
          )
      END as ancestors
    SQL
  end
  # rubocop:enable MethodLength

  def select_updates_count
    <<~SQL
    (
      SELECT count(v.id) AS updates_count
      FROM versions v
      WHERE v.item_id = people.id
        AND v.item_type = 'Person'
        AND v.event = 'update'
    )
    SQL
  end

  def selected_columns
    <<~SQL
      people.id,
      people.given_name || ' ' || people.surname AS full_name,
      people.location_in_building || ', ' || people.building || ', ' || people.city AS address,
      people.login_count,
      people.last_login_at,
      groups.name AS team_name,
      #{select_ancestors},
      memberships.role AS team_role,
      #{select_updates_count} AS updates_count
    SQL
  end

end
