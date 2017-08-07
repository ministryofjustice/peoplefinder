require 'csv'

class PersonCsvParser

  attr_reader :header, :records

  Header = Struct.new(:columns, :original, :unrecognized_columns) do
    def line_number
      1
    end
  end

  Record = Struct.new(:line_number, :fields, :original)

  def initialize(serialized)
    @unrecognized_columns = []
    @rows = CSV.new(serialized).to_a
    @header = parse_header(@rows.first)
    @records = parse_records(@rows.drop(1))
  end

  private

  def parse_header(row)
    columns = row.map { |s| infer_header(s.strip) }.compact
    @header = Header.new(columns, row.to_csv.chomp, @unrecognized_columns)
  end

  def parse_records(rows)
    @records = rows.map.with_index do |row, i|
      fields = Hash[header.columns.zip(row)]
      Record.new(i + 2, fields, row.to_csv.chomp)
    end
  end

  def infer_header(str)
    matches = header_matches.select { |_k, v| str =~ v }.keys
    @unrecognized_columns.push(str) if matches.empty?
    matches.first
  end

  def header_matches
    {
      given_name: /given|first/i,
      surname: /surname|last|family/i,
      email: /email|e-mail/i,
      primary_phone_number: /primary_phone_number|primary_phone/i,
      secondary_phone_number: /secondary_phone_number|secondary_phone/i,
      pager_number: /pager_number|pager/i,
      building: /^building$|^location1$|^address$|^address1$/i,
      location_in_building: /location_in_building|location2|address2|room/i,
      city: /city|town/i,
      description: /description|extra_information/i
    }
  end
end
