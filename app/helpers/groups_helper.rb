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
end
