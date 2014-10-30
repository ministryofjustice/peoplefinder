require 'peoplefinder'

module Peoplefinder::PeopleHelper
  def day_name(symbol)
    I18n.t(symbol, scope: [:peoplefinder, :people, :day_names])
  end

  def day_symbol(symbol)
    I18n.t(symbol, scope: [:peoplefinder, :people, :day_symbols])
  end

  def profile_image_tag(person, source, options = {})
    image_tag(source, options.merge(alt: "Current photo of #{ person }"))
  end
end
