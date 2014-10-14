require 'peoplefinder'

class Peoplefinder::GroupHierarchy
  def initialize(root)
    @root = root
  end

  def to_hash
    return {} unless @root
    export(@root)
  end

  def to_group_id_list
    @root.subtree_ids
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

  def children(group)
    child_map[group.id].sort_by(&:name)
  end

  def group_path(lg)
    Peoplefinder::Engine.routes.url_helpers.group_path(id: lg.to_param)
  end

  def child_map
    @child_map ||= Hash.new { |h, k| h[k] = [] }.tap { |hash|
      Peoplefinder::Group.all.each do |group|
        hash[group.parent_id] << group
      end
    }
  end
end
