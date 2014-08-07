class GroupHierarchy
  def initialize(root)
    @root = root
  end

  def to_hash
    export(@root)
  end

private

  def export(group)
    {
      name: group.name,
      url: Rails.application.routes.url_helpers.group_path(group),
      children: group.children.map { |g| export(g) }
    }
  end
end
