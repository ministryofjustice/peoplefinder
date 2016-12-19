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
      building: ''
    )
  end

  def dirty_recipient
    @dirty_recipient ||= recipient.tap do
      recipient.email = 'fred.john.bloggs@fake-moj.justice.gov.uk'
      recipient.primary_phone_number = '0123 456 789'
      recipient.location_in_building = ''
      recipient.building = 'St Pancras'
      recipient.works_monday = false
      recipient.works_saturday = true
      recipient.memberships.build(group: Group.first, role: "Lead Developer", leader: true, subscribed: false)
    end
  end

  # person who caused email to be sent
  # e.g. by updating/deleting another users profile, suggesting a change
  def instigator
    @instigator ||= Person.find_or_create_by!(given_name: 'Insti', surname: 'Gator', email: 'insti.gator@fake-moj.justice.gov.uk')
  end

end
