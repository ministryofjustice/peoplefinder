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
    clean_recipient
    @dirty_recipient = recipient
    @dirty_recipient.tap do |dr|
      dr.assign_attributes mass_person_attrs(dr)
      dr.save!
    end
  end

  def instigator
    @instigator ||= Person.find_or_create_by!(given_name: 'Insti', surname: 'Gator', email: 'insti.gator@fake-moj.justice.gov.uk')
  end

  def clean_recipient
    ['fred.bloggs@fake-moj.justice.gov.uk','fred.reese-bloggs@fake-moj.justice.gov.uk'].each do |email|
      recipient = Person.find_by(email: email)
      recipient.destroy if recipient
    end
    @recipient = nil
  end

  def mass_person_attrs person
    membership = person.reload.memberships.create(group_id: Group.second.id, role: "Executive Officer", leader: false, subscribed: true)
    {
      given_name: "Frederick",
      surname: 'Reese-Bloggs',
      primary_phone_number: '0123 456 789',
      secondary_phone_number: '07708 139 313',
      pager_number: '0113 432 567',
      email: 'fred.reese-bloggs@fake-moj.justice.gov.uk',
      location_in_building: '',
      building: 'St Pancras',
      city: 'Manchester',
      current_project: 'Office 365 Rollout',
      works_monday: false,
      works_saturday: true,
      description: 'new info',
      profile_photo_id: 1,
      memberships_attributes: {
        '0' => {
          role: 'The Boss',
          group_id: Group.first.id,
          leader: true,
          subscribed: false
        },
        '1' => {
          id: membership.id,
          group_id: membership.group_id,
          role: 'Chief Executive Officer',
          leader: true,
          subscribed: false
        }
      }
    }
  end

end
