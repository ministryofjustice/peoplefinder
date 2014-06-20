module GroupsHelper
  def level_description(group)
    %w[ Department Organisation Team ][[group.level, 2].min]
  end

  def child_level_description(group)
    %w[ Organisations Teams ][[group.level, 1].min]
  end
end
