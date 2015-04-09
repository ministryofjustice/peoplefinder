require 'virtus'
class PersonUpload
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :group_id
  attr_reader :import_count, :csv_errors

  def initialize(*)
    @csv_errors = []
    super
  end

  def save
    importer = CsvPeopleImporter.new(file.read)
    @import_count = importer.import
    @csv_errors = importer.errors
    @import_count
  end

  def persisted?
    false
  end
end
