module UploadHelper

  def required_headers
    headers(PersonCsvImporter::REQUIRED_COLUMNS, tag: :code, separator: ' ')
  end

  def optional_headers
    headers(PersonCsvImporter::OPTIONAL_COLUMNS, tag: :code, separator: ' ')
  end

  def csv_headers
    headers(PersonCsvImporter::REQUIRED_COLUMNS + PersonCsvImporter::OPTIONAL_COLUMNS, tag: nil, separator: ',')
  end

  private

  def headers(header_collection, options = { tag: nil, separator: ',' })
    return header_collection.join(options[:separator]) if options[:tag].nil?

    header_collection.map do |column_name|
      content_tag(options[:tag]) do
        concat column_name.to_s
      end
    end.join(options[:separator]).html_safe
  end

end
