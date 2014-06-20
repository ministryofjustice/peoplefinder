class Department
  include Singleton
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def children
    Group.orphans
  end

  def name
    "Ministry of Justice"
  end

  def to_s
    name
  end

  def parent
    nil
  end

  def description
    nil
  end

  def persisted?
    false
  end

  def editable?
    false
  end

  def type_of_children
    "Organisations"
  end
end
