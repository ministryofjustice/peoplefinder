module GroupsHelper
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
