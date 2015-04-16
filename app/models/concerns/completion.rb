# Why is this a Concern? It really isn't.
#
module Concerns::Completion
  extend ActiveSupport::Concern

  ADEQUATE_FIELDS = [
    :image, :location_in_building, :building, :city, :primary_phone_number
  ]

  COMPLETION_FIELDS = [
    :given_name, :surname, :email, :location_in_building, :building, :city,
    :primary_phone_number, :groups, :image
  ]

  included do
    def self.inadequate_profiles
      criteria = ADEQUATE_FIELDS.map { |f| "COALESCE(#{f}, '') = ''" }.join(' OR ')
      where(criteria).order(:email)
    end

    def self.overall_completion
      #
      # Calculate a total completion score. This is the total number of
      # COMPLETION_FIELDS present across all people in the database.
      #
      # Note the oddity with groups: the presence of a group is actually a
      # question of whether there are one or more memberships associated with
      # the person. As all the other fields are text, we translate this into
      # 'Y' or '' to work with the generic CASE + coalesce sum expression
      # generated from COMPLETION_FIELDS.
      #
      sum_expression = COMPLETION_FIELDS.map { |f|
        "CASE WHEN coalesce(#{f}, '') = '' THEN 0 ELSE 1 END"
      }.join(' + ')
      completed_fields = connection.execute(%{
        SELECT sum(#{sum_expression}) AS completed FROM (
          SELECT people.*,
            CASE WHEN count(memberships.id) > 0 THEN 'Y' ELSE '' END AS groups
          FROM people LEFT OUTER JOIN memberships
          ON memberships.person_id = people.id
          GROUP BY people.id) AS subquery
      })[0]['completed'].to_f

      # Turn it into a percentage. The denominator is the total number of
      # completed fields possible, i.e. the number of people multiplied by the
      # number of items in COMPLETION_FIELDS.
      #
      (completed_fields * 100.0) / (count * COMPLETION_FIELDS.length)
    end

    def completion_score
      completed = COMPLETION_FIELDS.map { |f| send(f).present? }
      (100 * completed.select { |f| f }.length) / COMPLETION_FIELDS.length
    end

    def incomplete?
      completion_score < 100
    end

    def complete?
      !incomplete?
    end

    def needed_for_completion?(field)
      COMPLETION_FIELDS.include?(field) && send(field).blank?
    end
  end
end
