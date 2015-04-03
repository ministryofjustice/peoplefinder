require 'rails_helper'

shared_examples 'existing person returned' do
  it 'returns the matching person' do
    is_expected.to eql(person)
  end
end
shared_examples 'new person created' do
  it 'returns a person model' do
    is_expected.to be_a(Person)
  end

  describe 'the person' do
    it 'has correct e-mail address'  do
      expect(subject.email).to eql(expected_email)
    end
    it 'has correct name' do
      expect(subject.name).to eql(expected_name)
    end
  end
end

RSpec.describe FindCreatePerson, type: :service do
  let(:valid_auth_hash) do
    {
      'info' => {
        'email' => 'example.user@digital.justice.gov.uk',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'name' => 'John Doe'
      }
    }
  end
  let(:rogue_auth_hash) do
    valid_auth_hash.deep_merge(
        'info' => { 'email' => 'rogue.user@example.com' }
    )
  end

  describe '.from_auth_hash' do
    subject { described_class.from_auth_hash(auth_hash) }

    context 'for an existing person' do
      let(:auth_hash) { valid_auth_hash }
      let!(:person) { create(:person_with_multiple_logins, email: valid_auth_hash['info']['email'], surname: 'Bob') }

      it_behaves_like 'existing person returned'
    end

    context 'for a new person' do
      let(:auth_hash) { valid_auth_hash }

      it_behaves_like 'new person created' do
        let(:expected_email) { 'example.user@digital.justice.gov.uk' }
        let(:expected_name) { 'John Doe' }
      end
    end

    context 'for invalid email' do
      let(:auth_hash) { rogue_auth_hash }
      it { is_expected.to be_nil }
    end
  end

  describe '.from_token' do
    let(:token) { Token.create(user_email: 'aled.jones@digital.justice.gov.uk') }
    subject { described_class.from_token(token) }

    context 'for a new person' do
      it_behaves_like 'new person created' do
        let(:expected_email) { token.user_email }
        let(:expected_name) { 'Aled Jones' }
      end
    end

    context 'for an existing person' do
      let!(:person) { create(:person_with_multiple_logins, given_name: 'aled', surname: 'jones', email: 'aled.jones@digital.justice.gov.uk') }

      it_behaves_like 'existing person returned'
    end
  end
end
