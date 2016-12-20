module PreviewHelper

  private

  def team
    @team ||= Group.find_or_create_by!(name: 'Preview Test Team', description: nil, parent: Group.at_depth(0).first)
  end

  def recipient
    @recipient ||= Person.find_or_create_by!(
      given_name: 'Fred',
      surname: 'Bloggs',
      email: 'fred.bloggs@fake-moj.justice.gov.uk',
      primary_phone_number: '0555 555 555',
      location_in_building: 'room 101',
      building: '',
      description: 'old info'
    )
  end

  def dirty_recipient
    @dirty_recipient ||= recipient.tap do
      recipient.given_name = "Frederick"
      recipient.surname = 'Reese-Bloggs'
      recipient.primary_phone_number = '0123 456 789'
      recipient.secondary_phone_number = '07708 139 313'
      recipient.pager_number = '0113 432 567'
      recipient.email = 'fred.reese-bloggs@fake-moj.justice.gov.uk'
      recipient.location_in_building = ''
      recipient.building = 'St Pancras'
      recipient.city = 'Manchester'
      recipient.current_project = 'Office 365 Rollout'
      recipient.works_monday = false
      recipient.works_saturday = true
      recipient.description = 'new info'
      recipient.profile_photo_id = 1
      recipient.memberships.build(group: Group.first, role: "Lead Developer", leader: true, subscribed: false)
    end
  end

  # person who caused email to be sent
  # e.g. by updating/deleting another users profile, suggesting a change
  def instigator
    @instigator ||= Person.find_or_create_by!(given_name: 'Insti', surname: 'Gator', email: 'insti.gator@fake-moj.justice.gov.uk')
  end

end
