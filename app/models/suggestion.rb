require 'virtus'
class Suggestion
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  PROBLEMS = %i(
    missing_fields incorrect_fields duplicate_profile inappropriate_content
    person_left
  ).freeze

  attribute :missing_fields, Boolean, default: false
  attribute :missing_fields_info, String

  attribute :incorrect_fields, Boolean, default: false

  POTENTIALLY_INCORRECT_FIELDS = %i(
    first_name
    last_name
    roles
    location_of_work
    working_days
    phone_number
    pager_number
    image
  ).freeze

  POTENTIALLY_INCORRECT_FIELDS.each do |field|
    attribute :"incorrect_#{field}", Boolean, default: false
  end

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
    POTENTIALLY_INCORRECT_FIELDS.
      select { |f| send(:"incorrect_#{f}") }.
      map { |sym| sym.to_s.humanize }
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
