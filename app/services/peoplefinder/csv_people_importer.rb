require 'csv'

module Peoplefinder
  class CsvPeopleImporter
    COLUMNS = %w[given_name surname email]

    attr_reader :errors

    def initialize(csv)
      @rows, @header_row = process_csv(csv)
      @valid = nil
    end

    def valid?
      return @valid unless @valid.nil?

      @errors = validate_csv

      @valid = @errors.empty?
    end

    def import
      result = nil

      if valid?
        result = 0

        @rows.each do |row|
          if Person.create(row.to_h.slice(*COLUMNS))
            result += 1
          end
        end
      end

      result
    end

  private

    def process_csv(csv)
      rows = CSV.new(csv, headers: true, return_headers: true).to_a
      header_row = rows.shift

      [rows, header_row]
    end

    def missing_columns
      COLUMNS.reject { |column| @header_row.include?(column) }
    end

    def validate_csv
      errors = []

      if missing_columns.empty?
        @rows.each do |row|
          person = Person.new(row.to_h.slice(*COLUMNS))
          unless person.valid?
            errors << %(row "#{row.to_csv.strip}": #{person.errors.full_messages.join(', ')})
          end
        end
      else
        errors = missing_columns.map { |column| "#{column} column is missing" }
      end

      errors
    end
  end
end
