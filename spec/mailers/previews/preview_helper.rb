module PreviewHelper

  private

  def team
    @team ||= Group.find_or_create_by(name: 'Testimus\'s Team', description: nil)
  end

  def recipient
    @recipient ||= Person.find_or_create_by(given_name: 'Testimus', surname: 'Recipientus', email: 'testimus.recipientus@fake-moj.justice.gov.uk')
  end

  # person who caused email to be sent
  # i.e. by updating/deleting another users profile
  def instigator
    @instigator ||= Person.find_or_create_by(given_name: 'Insti', surname: 'Gator', email: 'insti.gator@fake-moj.justice.gov.uk')
  end

end
