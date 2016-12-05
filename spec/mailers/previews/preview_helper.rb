module PreviewHelper

  private

  def team
    @team ||= Group.find_or_create_by!(name: 'Preview Test Team', description: nil, parent: Group.at_depth(0).first)
  end

  def recipient
    @recipient ||= Person.find_or_create_by!(given_name: 'Testimus', surname: 'Recipientus', email: 'testimus.recipientus@fake-moj.justice.gov.uk')
  end

  def dirty_recipient
    @dirty_recipient ||= recipient.tap do
      recipient.email = 'changed.user@fake-moj.justice.gov.uk'
      recipient.primary_phone_number = '0123 456 789'
      recipient.location_in_building = '10.51'
    end
  end

  # person who caused email to be sent
  # e.g. by updating/deleting another users profile, suggesting a change
  def instigator
    @instigator ||= Person.find_or_create_by!(given_name: 'Insti', surname: 'Gator', email: 'insti.gator@fake-moj.justice.gov.uk')
  end

end
