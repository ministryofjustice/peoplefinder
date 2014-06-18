class Department
  include Singleton

  def children
    Group.orphans
  end

  def name
    "Department of Justice"
  end

  def to_s
    name
  end
end
