module ApplicationHelper
  def body_class
    Rails.configuration.phase + " " + Rails.configuration.product_type
  end
end
