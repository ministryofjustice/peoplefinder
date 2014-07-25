module AuditsHelper
  def event_description(version)
    if version.event == 'create'
      "New #{version.item_type}"
    elsif version.event == 'destroy'
      "Deleted #{version.item_type}"
    elsif version.event == 'update'
      "#{version.item_type} Edited"
    end
  end

  def link_to_edited_item(version)
    if version.item && !version.item.is_a?(Membership)
      link_to(version.item)
    end
  end
end
