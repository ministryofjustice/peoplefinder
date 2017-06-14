module OrgBrowserHelper

  def current_group? group
    @group_nav_item = group
    group_nav_item_is_self?
  end

  private

  # when editing a group you should not be able to select that group as its own parent
  #
  def group_nav_item_is_self?
    @group && @group.id == @group_nav_item.id && controller.controller_name == 'groups'
  end

end
