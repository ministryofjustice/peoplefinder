require 'virtus'
class Suggestion
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  PROBLEMS = %i[
    missing_fields incorrect_fields duplicate_profile inappropriate_content
    person_left
  ]

  attribute :missing_fields, Boolean, default: false
  attribute :missing_fields_info, String

  attribute :incorrect_fields, Boolean, default: false
  attribute :incorrect_first_name, Boolean, default: false
  attribute :incorrect_last_name, Boolean, default: false
  attribute :incorrect_roles, Boolean, default: false
  attribute :incorrect_location_of_work, Boolean, default: false
  attribute :incorrect_working_days, Boolean, default: false

  attribute :duplicate_profile, Boolean, default: false

  attribute :inappropriate_content, Boolean, default: false
  attribute :inappropriate_content_info, String

  attribute :person_left, Boolean, default: false
  attribute :person_left_info, String

  validate :must_select_problem
  validates :missing_fields_info, presence: true, if: -> (s) { s.missing_fields }
  validate :must_provide_incorrect_field, if: -> (s) { s.incorrect_fields }
  validates :inappropriate_content_info, presence: true, if: -> (s) { s.inappropriate_content }

  def persisted?
    false
  end

  def incorrect_fields_info
    fields = %w[first_name last_name roles location_of_work working_days]
    incorrect_fields = fields.select { |f| send("incorrect_#{f}") }
    incorrect_fields.map(&:humanize)
  end

  def for_person?
    missing_fields || incorrect_fields
  end

  def for_admin?
    duplicate_profile || inappropriate_content || person_left
  end

private

  def must_select_problem
    problem_fields = PROBLEMS.map { |problem| send(problem) }
    if problem_fields.all?(&:blank?)
      errors.add(:base, 'a problem should be selected')
    end
  end

  def must_provide_incorrect_field
    if incorrect_fields_info.empty?
      errors.add(:base, 'should specify at least one incorrect field')
    end
  end
end
