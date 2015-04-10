require 'csv'

class CsvPeopleImporter
  COLUMNS = %w[given_name surname email]

  ErrorRow = Struct.new(:line_number, :raw, :messages) do
    def to_s
      'line %d "%s": %s' % [line_number, raw, messages.join(', ')]
    end
  end

  attr_reader :errors

  def initialize(csv, creation_options = {})
    @rows, @header_row = process_csv(csv)
    @creation_options = creation_options
    @valid = nil
  end

  def valid?
    return @valid unless @valid.nil?

    @errors = validate_csv

    @valid = @errors.empty?
  end

  def import
    return nil unless valid?

    @rows.inject(0) { |result, row|
      result + (Person.create(row_to_params(row)) ? 1 : 0)
    }
  end

private

  def row_to_params(row)
    @creation_options.merge(row.to_h.slice(*COLUMNS))
  end

  def process_csv(csv)
    rows = CSV.new(csv, headers: true, return_headers: true).to_a
    header_row = rows.shift

    [rows, header_row]
  end

  def missing_columns
    COLUMNS.reject { |column| @header_row.include?(column) }
  end

  def validate_csv
    missing_columns.any? ? validate_columns : validate_rows
  end

  def validate_rows
    errors = []
    @rows.each.with_index do |row, i|
      person = Person.new(row.to_h.slice(*COLUMNS))
      unless person.valid?
        errors <<
          ErrorRow.new(i + 2, row.to_csv.strip, person.errors.full_messages)
      end
    end
    errors
  end

  def validate_columns
    missing_columns.map { |column|
      ErrorRow.new(1, @header_row.to_csv.strip, ["#{column} column is missing"])
    }
  end
end
