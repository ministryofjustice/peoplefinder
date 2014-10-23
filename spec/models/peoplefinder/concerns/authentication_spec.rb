require 'rails_helper'

RSpec.describe 'Authentication' do # rubocop:disable RSpec/DescribeClass
  context 'via auth hash' do
    it 'creates a new person from a valid auth_hash' do
      person = person_from_auth_hash(valid_auth_hash)
      expect(person).not_to be_nil
      expect(person.email).to eql('example.user@digital.justice.gov.uk')
      expect(person.name).to eql('John Doe')
    end

    it 'returns an existing person called Bob from a valid auth_hash' do
      Peoplefinder::Person.create(email: valid_auth_hash['info']['email'], surname: 'Bob')

      person = person_from_auth_hash(valid_auth_hash)
      expect(person.email).to eql('example.user@digital.justice.gov.uk')
      expect(person.name).to eql('Bob')
    end

    it 'returns nil from an auth_hash with the wrong domain' do
      person = person_from_auth_hash(rogue_auth_hash)
      expect(person).to be_nil
    end
  end

  context 'via token' do
    let(:token) { Peoplefinder::Token.create(user_email: 'aled.jones@digitial.justice.gov.uk') }
    let(:person) { Peoplefinder::Person.from_token(token) }

    it 'creates a new person from a valid token' do
      expect(person.email).to eql(token.user_email)
      expect(person.name).to eql('Aled Jones')
    end

    it 'returns an existing person called aled jones from a valid token' do
      aled_jones = create(:person,
        given_name: 'aled', surname: 'jones', email: 'aled.jones@digitial.justice.gov.uk')

      expect(person).to eql(aled_jones)
    end
  end

  def valid_auth_hash
    {
      'info' => {
        'email' => 'example.user@digital.justice.gov.uk',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'name' => 'John Doe'
      }
    }
  end

  def rogue_auth_hash
    valid_auth_hash.deep_merge(
      'info' => { 'email' => 'rogue.user@example.com' }
    )
  end

  def person_from_auth_hash(auth_hash)
    Peoplefinder::Person.from_auth_hash(auth_hash)
  end
end
