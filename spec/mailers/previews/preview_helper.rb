module PreviewHelper

  private

  def team
    @team ||= Group.find_or_create_by!(name: 'Preview Test Team', description: nil, parent: Group.at_depth(0).first)
  end

  def recipient
    @recipient ||= Person.find_or_create_by!(given_name: 'Testimus', surname: 'Recipientus', email: 'testimus.recipientus@fake-moj.justice.gov.uk')
  end

  # person who caused email to be sent
  # e.g. by updating/deleting another users profile, suggesting a change
  def instigator
    @instigator ||= Person.find_or_create_by!(given_name: 'Insti', surname: 'Gator', email: 'insti.gator@fake-moj.justice.gov.uk')
  end

end
