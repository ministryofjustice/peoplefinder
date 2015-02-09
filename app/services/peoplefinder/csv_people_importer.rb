require 'csv'

module Peoplefinder
  class CsvPeopleImporter
    COLUMNS = [:given_name, :surname, :email]

    attr_reader :errors

    def initialize(csv)
      @csv = csv
    end

    def valid?
      @errors = []

      if missing_columns.empty?
        csv_rows.each do |row|
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

    def csv_rows
      CSV.new(@csv, headers: true, skip_blanks: true, header_converters: :symbol)
    end

    def missing_columns
      header_row = CSV.new(@csv,
        headers: true, return_headers: true, header_converters: :symbol).first

      COLUMNS.reject { |column| header_row.include?(column) }
    end
  end
end
