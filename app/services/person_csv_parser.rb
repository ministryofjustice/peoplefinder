require 'csv'

class PersonCsvParser
  Header = Struct.new(:columns, :original) do
    def line_number
      1
    end
  end

  Record = Struct.new(:line_number, :fields, :original)

  def initialize(serialized)
    @rows = CSV.new(serialized).to_a
  end

  def header
    columns = @rows.first.map { |s| infer_header(s) }.compact
    Header.new(columns, @rows.first.to_csv.chomp)
  end

  def records
    @rows.drop(1).map.with_index do |row, i|
      fields = Hash[header.columns.zip(row)]
      Record.new(i + 2, fields, row.to_csv.chomp)
    end
  end

  private

  def infer_header(str)
    header_matches.select { |_k, v| v =~ str }.keys.first
  end

  def header_matches
    {
      given_name: /given|first/i,
      surname: /surname|last|family/i,
      email: /email|e-mail/i,
      primary_phone_number: /primary_phone_number|phone/i,
      building: /^building$|^location1$|^address$|^address1$/i,
      location_in_building: /location_in_building|location2|address2|room/i,
      city: /city|town/i
    }
  end
end
