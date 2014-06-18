class Department
  include Singleton

  def children
    Group.orphans
  end

  def name
    "Ministry of Justice"
  end

  def to_s
    name
  end
end
