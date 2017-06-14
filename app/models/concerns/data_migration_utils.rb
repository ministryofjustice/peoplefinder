module Concerns::DataMigrationUtils
  extend ActiveSupport::Concern

  included do
    scope :non_team_members, -> { where(non_member_sql) }

    def self.non_member_sql
      <<~SQL
        NOT EXISTS (SELECT 1 FROM memberships WHERE memberships.person_id = people.id)
      SQL
    end
  end
end
