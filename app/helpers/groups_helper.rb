module GroupsHelper
  def level_symbol(level)
    levels = [:department, :organization, :team]
    index = [level, levels.length - 1].min
    levels[index]
  end

  def about_group_title(group)
    I18n.t(level_symbol(group.level.succ), scope: [:groups, :about])
  end

  def about_group_responsibilities_title(group)
    I18n.t(level_symbol(group.level.succ), scope: [:groups, :responsibilities])
  end

  def child_group_list_title(group)
    I18n.t(level_symbol(group.level.succ), scope: [:groups, :list])
  end

  def new_child_group_cta(group)
    I18n.t(level_symbol(group.level.succ), scope: [:groups, :add_cta])
  end

  def display_children_of_group(group)
    !group.leaf_node?
  end

  def display_view_all_people_link_for_group(group)
    !group.leaf_node? && group.non_leaderships.present?
  end

  def display_all_people_in_group(group)
    group.leaf_node? && group.non_leaderships.present?
  end
end
