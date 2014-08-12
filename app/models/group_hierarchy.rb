class GroupHierarchy
  FIELDS = [:id, :name, :slug, :parent_id]
  LiteGroup = Struct.new(*FIELDS)

  def initialize(root)
    @root = root
  end

  def to_hash
    export(@root)
  end

  def to_group_id_list
    export_id(@root).flatten
  end

private

  def export(group)
    {
      id: group.id,
      name: group.name,
      url: group_path(group),
      children: children(group).map { |g| export(g) }
    }
  end

  def export_id(group)
    [
      group.id,
      children(group).map { |g| export_id(g) }
    ]
  end

  def children(group)
    lookup.select { |g| g.parent_id == group.id }.sort_by(&:name)
  end

  def group_path(lg)
    Rails.application.routes.url_helpers.group_path(id: lg.slug)
  end

  def lookup
    @lookup ||= Group.pluck(*FIELDS).map { |a| LiteGroup.new(*a) }
  end
end
