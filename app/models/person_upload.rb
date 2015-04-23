require 'virtus'
class PersonUpload
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :group_id
  attr_reader :import_count, :csv_errors

  validates :file, presence: true
  validates :group_id, presence: true

  def initialize(*)
    @csv_errors = []
    super
  end

  def save
    return nil unless valid?

    groups = Group.where(id: group_id)
    importer = PersonCsvImporter.new(file.read, groups: groups)
    @import_count = importer.import || 0
    @csv_errors = importer.errors
    @import_count > 0
  end

  def persisted?
    false
  end
end
