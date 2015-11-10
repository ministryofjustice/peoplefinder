module MojHelper
  def config_item(key)
    Rails.configuration.send(key)
  end

  def logo_image
    image_tag('co_logo_horizontal_36x246.png',
      class: 'content',
      width: 36, height: 246, alt: 'Cabinet Office')
  end
end
