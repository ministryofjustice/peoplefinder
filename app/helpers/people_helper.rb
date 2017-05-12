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

  # e.g. profile_image_tag person, link: false
  def profile_image_tag(person, options = {})
    source = profile_image_source(person, options)
    options[:link_uri] = person_path(person) if add_image_link?(options)
    options[:alt_text] = "Current photo of #{person}"
    profile_or_team_image_div source, options
  end

  def team_image_tag team, options = {}
    source = 'medium_team.png'
    options[:link_uri] = group_path(team) if add_image_link?(options)
    options[:alt_text] = "Team icon for #{team.name}"
    profile_or_team_image_div source, options
  end

  def edit_person_link(name, person, options = {})
    link_to name,
      edit_person_path(person, activity: options[:activity]),
      options.
      except(:activity).
      merge(data: edit_profile_analytics_attributes(person.id))
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

  def image_tag_wrapper source, options
    image_tag(
      source,
      options.
        except(:version, :link, :link_uri, :alt_text).
        merge(alt: options[:alt_text], class: 'media-object')
    )
  end

  def profile_or_team_image_div source, options
    content_tag(:div, class: 'maginot') do
      if options.key?(:link_uri)
        content_tag(:a, href: options[:link_uri]) do
          image_tag_wrapper(source, options)
        end
      else
        image_tag_wrapper(source, options)
      end
    end
  end

  # default to having an image link unless 'link: false' passed explicitly
  def add_image_link? options
    !options.key?(:link) || options[:link]
  end

  def profile_image_source(person, options)
    version = options.fetch(:version, :medium)
    url_for_image person.profile_image.try(version)
  end

  def url_for_image image
    if image.try(:file).respond_to? :authenticated_url
      image.file.authenticated_url
    else
      image || 'medium_no_photo.png'
    end
  end

end
