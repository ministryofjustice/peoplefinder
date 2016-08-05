module PeopleHelper

  def days_worked person
    days = []
    Person::DAYS_WORKED.each do |day|
      days.push day_name(day) if person.send(day)
    end
    days.to_sentence
  end

  def day_name(symbol)
    I18n.t(symbol, scope: [:people, :day_names])
  end

  def day_symbol(symbol)
    I18n.t(symbol, scope: [:people, :day_symbols])
  end

  def profile_image_tag(person, options = {})
    source = profile_image_source(person, options)
    alt_text = "Current photo of #{person}"
    profile_image_div source, alt_text, options
  end

  def team_image_tag team, options = {}
    profile_image_div 'medium_team.png', "Team icon for #{team.name}", options
  end

  def profile_image_div source, alt_text, options
    content_tag(:div, class: 'maginot') do
      image_tag(source, options.merge(alt: alt_text)) +
        content_tag(:div, class: 'barrier') {}
    end
  end

  # Why do we need to go to this trouble to repeat new_person/edit_person? you
  # might wonder. Well, form_for only allows us to replace the form class, not
  # augment it, and we rely on the default classes elsewhere.
  #
  def person_form_class(person, activity)
    [person.new_record? ? 'new_person' : 'edit_person'].tap do |classes|
      classes << 'completing' if activity == 'complete'
    end.join(' ')
  end

  private

  def profile_image_source(person, options)
    version = options.fetch(:version, :medium)
    options.delete(:version)
    person.profile_image.try(version) || 'medium_no_photo.png'
  end

end
