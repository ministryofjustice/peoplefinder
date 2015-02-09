require 'csv'

module Peoplefinder
  class CsvPeopleImporter
    COLUMNS = %w[given_name surname email]

    attr_reader :errors

    def initialize(csv)
      @csv = CSV.new(csv, headers: true, return_headers: true)
      @header_row = @csv.first
    end

    def valid?
      @errors = []

      if missing_columns.empty?
        @csv.each do |row|
          person = Person.new(row.to_h.slice(*COLUMNS))
          unless person.valid?
            @errors << %(row "#{row.to_csv.strip}": #{person.errors.full_messages.join(', ')})
          end
        end
      else
        @errors = missing_columns.map { |column| "#{column} column is missing" }
      end

      @errors.empty?
    end

  private

    def missing_columns
      COLUMNS.reject { |column| @header_row.include?(column) }
    end
  end
end
