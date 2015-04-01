require 'virtus'
class PersonUpload
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :group_id
  attr_reader :import_count

  def save
    @import_count = CsvPeopleImporter.new(file.read).import
  end

  def persisted?
    false
  end
end
