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
    case str
    when /given|first/i
      :given_name
    when /surname|last|family/i
      :surname
    when /email|e-mail/i
      :email
    else
      nil
    end
  end
end
