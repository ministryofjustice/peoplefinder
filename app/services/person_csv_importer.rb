require 'csv'
require 'forwardable'
require 'yaml'

class PersonCsvImporter
  extend Forwardable

  REQUIRED_COLUMNS = %i(given_name surname email).freeze
  OPTIONAL_COLUMNS = %i(
    primary_phone_number
    secondary_phone_number
    pager_number
    building
    location_in_building
    city
    role
    description
  ).freeze

  ErrorRow = Struct.new(:line_number, :raw, :messages) do
    def to_s
      'line %d "%s": %s' % [line_number, raw, messages.join(', ')]
    end
  end

  attr_reader :errors, :serialized_records

  def initialize(serialized, creation_options = {})
    @serialized_records = serialized
    @creation_options = creation_options
    @parser = PersonCsvParser.new(serialized)
    @valid = nil
  end

  def valid?
    return @valid unless @valid.nil?
    @errors = column_errors.any? ? column_errors : row_errors
    @valid = @errors.empty?
  end

  def import
    return nil unless valid?
    PersonImportJob.perform_later(serialized_records, serialized_group_ids)
    people.length
  end

  def serialized_group_ids
    YAML.dump(@creation_options[:groups].map(&:id))
  end

  def self.deserialize_group_ids(serialized_group_ids)
    group_ids = YAML.load(serialized_group_ids)
    Group.where(id: group_ids)
  end

  def self.person_fields(hash)
    hash.merge(email: EmailExtractor.new.extract(hash[:email])).
      except(:role)
  end

  private

  def_delegators :@parser, :records, :header

  def people
    @people ||= records.map do |record|
      Person.new(@creation_options.merge(self.class.person_fields(record.fields))).tap do |person|
        person.memberships.first.role = record.fields[:role]
      end
    end
  end

  def missing_columns
    REQUIRED_COLUMNS - header.columns
  end

  def missing_column_errors
    missing_columns.map do |column|
      ErrorRow.new(1, header.original, ["#{column} column is missing"])
    end
  end

  def unrecognized_column_errors
    header.unrecognized_columns.map do |column|
      ErrorRow.new(1, header.original, ["#{column} column is not recognized"])
    end
  end

  def too_many_columns?
    original_header_size = CSV.new(header.original).to_a.first.size
    original_header_size > REQUIRED_COLUMNS.size + OPTIONAL_COLUMNS.size
  end

  def too_many_columns_error
    too_many_columns? ? [ErrorRow.new(1, header.original, ['There are more columns than expected'])] : []
  end

  def column_errors
    too_many_columns_error + missing_column_errors + unrecognized_column_errors
  end

  def too_many_rows_error
    if too_many_rows?
      [ErrorRow.new('-', '-', ["Too many rows - a maximum of #{max_row_upload} rows can be processed"])]
    else
      []
    end
  end

  def max_row_upload
    2000
  end

  def too_many_rows?
    people.size > max_row_upload
  end

  def row_errors
    too_many_rows_error + people_record_errors
  end

  def people_record_errors
    people.zip(records).map do |person, record|
      person.skip_must_have_team = true
      if person.valid?
        nil
      else
        ErrorRow.new(
          record.line_number, record.original, person.errors.full_messages
        )
      end
    end.compact
  end

end
