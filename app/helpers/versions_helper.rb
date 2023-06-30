module VersionsHelper
  def view_template(version)
    version.membership? ? "membership" : "general"
  end

  def link_to_edited_item(version)
    if version.item && !version.item.is_a?(Membership)
      link_to(version.item, version.item)
    end
  end
end
