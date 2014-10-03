class UserUpload
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :file

  def initialize(opts = {})
    self.file = opts[:file]
  end

  def save
    UserImporter.new(file.read).import
  rescue
    false
  end

  def persisted?
    false
  end
end
