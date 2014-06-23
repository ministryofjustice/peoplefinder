module ApplicationHelper
  def body_class
    Rails.configuration.phase + " " + Rails.configuration.product_type
  end

  def last_update
    if current_object = @person || @group
      unless current_object.updated_at.blank?
        "Last updated: #{ current_object.updated_at.strftime('%d %b %Y') }."
      end
    end
  end
end
