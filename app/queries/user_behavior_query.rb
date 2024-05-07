class UserBehaviorQuery < BaseQuery
  DATE_STRING_FORMAT = "%d-%m-%Y".freeze

  attr_reader :relation

  def initialize # rubocop:disable Lint/MissingSuper
    @relation = Person.all.unscoped
  end

  def call
    @relation
      .joins(joins_sql)
      .select(selected_columns)
      .order("people.id, full_name")
  end

  def data
    data = []
    call.find_in_batches do |people|
      people.each do |person|
        data << map_data_hash(person)
      end
    end
    data
  end

  def team_mapping
    @team_mapping ||= \
      Group.order(id: :asc)
      .pluck(:id, :name)
      .each_with_object({}) do |(id, name), mapping|
        mapping.merge!(id => name)
      end
  end

  def team_name_map(ancestor_ids, delimiter = " > ")
    names = ancestor_ids&.each_with_object([]) do |id, arr|
      arr.push team_mapping[id.to_i]
    end
    names&.join(delimiter)
  end

private

  def map_data_hash(rec)
    {
      id: rec.id,
      full_name: rec.full_name,
      address: rec.address, # can't use location as the name as this is a method on person model
      team_name: rec.team_name,
      ancestors: team_name_map(rec.ancestors),
      team_role: rec.team_role,
      main_email_address: rec.email,
      main_phone_number: rec.primary_phone_number,
      alternative_phone_number: rec.secondary_phone_number,
      alternative_email_address: rec.secondary_email,
      login_count: rec.login_count,
      last_login_at: rec.last_login_at&.strftime(DATE_STRING_FORMAT),
      updates_count: rec.updates_count,
      percent_complete: rec.completion_score,
    }
  end

  def joins_sql
    <<~SQL
      LEFT JOIN memberships ON memberships.person_id = people.id
      LEFT JOIN groups ON groups.id = memberships.group_id
    SQL
  end

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
      people.email,
      people.secondary_email,
      people.primary_phone_number,
      people.secondary_phone_number,
      people.login_count,
      people.last_login_at,
      groups.name AS team_name,
      regexp_split_to_array(groups.ancestry,'\/') AS ancestors,
      memberships.role AS team_role,
      #{select_updates_count} AS updates_count
    SQL
  end
end
