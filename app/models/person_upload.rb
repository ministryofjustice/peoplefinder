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
  validate :file_type

  def self.policy_class
    Admin::PersonUploadPolicy
  end

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

  private

  def file_type
    errors.add(:file, 'is an invalid type') unless csv_mime_type?(file)
  end

  def csv_mime_type? file
    if file
      mime_parts = file.content_type.split('/')
      [
        %w(text application).include?(mime_parts.first),
        %w(csv x-csv comma-separated-values x-comma-separated-values plain).include?(mime_parts.last)
      ].all?
    end
  end
end
