module OrgBrowserHelper

  def current_group_or_department? group
    @group_nav_item = group
    group_nav_item_is_self? || group_nav_item_is_department?
  end

  private

  # when editing a group you should not be able to select that group as its own parent
  #
  def group_nav_item_is_self?
    @group && @group.id == @group_nav_item.id && controller.controller_name == 'groups'
  end

  # when editing a person you should not be able to select the department
  #
  def group_nav_item_is_department?
    @group_nav_item == Group.department && controller.controller_name == 'people'
  end

end
