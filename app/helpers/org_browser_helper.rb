module OrgBrowserHelper
  def current_group_or_department? group
    (@group && @group.id == group.id) ||
      (group == Group.department && controller.controller_name == 'people')
  end
end
