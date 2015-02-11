require 'peoplefinder'

class Peoplefinder::Version < PaperTrail::Version
  self.table_name = 'versions'

  def self.public_user
    'Public user'
  end

  def creation?
    event == 'create'
  end

  def destruction?
    event == 'destroy'
  end

  def alteration?
    event == 'update'
  end

  def membership?
    item_type == 'Peoplefinder::Membership'
  end

  def undo
    return if membership?
    creation? ? item.destroy : reify.save
  end

  def event_description
    if creation?
      "New #{ item_type }"

    elsif destruction?
      "Deleted #{ item_type }"

    elsif alteration?
      "#{ item_type } Edited"
    end
  end

  def whodunnit
    stored = super
    case stored
    when /\A\d+\z/
      Peoplefinder::Person.find_by(id: stored.to_i)
    else
      stored
    end
  end
end
