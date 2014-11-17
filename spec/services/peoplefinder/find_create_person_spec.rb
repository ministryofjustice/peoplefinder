require 'rails_helper'

module Peoplefinder
  shared_examples 'existing person returned' do
    it 'returns the matching person' do
      is_expected.to eql(person)
    end
    describe 'the person' do
      it 'has increased login count' do
        expect(subject.login_count).to eql(11)
      end
      it 'has updated time of last login' do
        expect(subject.last_login_at).to eql(current_time)
      end
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
      it 'has login count 1' do
        expect(subject.login_count).to eql(1)
      end
      it 'has updated time of last login' do
        expect(subject.last_login_at).to eql(current_time)
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
    let(:current_time) { Time.now }

    before { Timecop.freeze(current_time) }
    after { Timecop.return }

    describe '.from_auth_hash' do
      subject { described_class.from_auth_hash(auth_hash) }

      context 'for an existing person' do
        let(:auth_hash) { valid_auth_hash }
        let!(:person) { create(:person_with_multiple_logins, email: valid_auth_hash['info']['email'], surname: 'Bob')}

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
      let(:token) { Token.create(user_email: 'aled.jones@digitial.justice.gov.uk') }
      subject { described_class.from_token(token)}

      context 'for a new person' do
        it_behaves_like 'new person created' do
          let(:expected_email) { token.user_email }
          let(:expected_name) { 'Aled Jones' }
        end
      end

      context 'for an existing person' do
        let!(:person) { create(:person_with_multiple_logins, given_name: 'aled', surname: 'jones', email: 'aled.jones@digitial.justice.gov.uk')}

        it_behaves_like 'existing person returned'
      end
    end

  end
end
