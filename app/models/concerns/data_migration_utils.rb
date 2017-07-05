module Concerns::DataMigrationUtils
  extend ActiveSupport::Concern

  included do
    scope :non_team_members, -> { unscoped.where(non_member_sql) }
    scope :department_members_in_other_teams, -> { department_members_in_other_teams_query }
  end

  class_methods do

    private

    def non_member_sql
      <<~SQL
        NOT EXISTS (SELECT 1 FROM memberships WHERE memberships.person_id = people.id)
      SQL
    end

    def department_members_in_other_teams_query
      unscoped.joins(:memberships).where(department_members_in_other_teams_conditions)
    end

    def department_members_in_other_teams_conditions
      dept_id = Group.department.id
      <<~SQL
        memberships.group_id = #{dept_id}
        AND memberships.leader = 'f'
        AND #{blank?('memberships.role')}
        AND EXISTS (SELECT 1
                    FROM memberships m2
                    WHERE m2.person_id = people.id AND m2.group_id != #{dept_id}
                    )
      SQL
    end

    def blank? column_name
      <<~SQL
        (
          length(regexp_replace(#{column_name},'[\s\t\n]+','','g')) = 0
          OR #{column_name} IS NULL
        )
      SQL
    end

  end
end
