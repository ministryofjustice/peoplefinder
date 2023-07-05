module OrgBrowserHelper
  # TODO: implement unselectable department or remove
  #
  def current_group_or_department?(group)
    group_nav_item_is_self?(group)
  end

private

  # when editing a group you should not be able to select that group as its own parent
  #
  def group_nav_item_is_self?(group_nav_item)
    @group && @group.id == group_nav_item.id && controller.controller_name == "groups" # rubocop:disable Rails/HelperInstanceVariable
  end
end
