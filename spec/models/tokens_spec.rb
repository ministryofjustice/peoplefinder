require 'rails_helper'

RSpec.describe Token, type: :model do
  include PermittedDomainHelper

  it 'generates a token' do
    token = create(:token)
    expect(token.value).to match(/\A[a-z0-9\-]{36}\z/)
  end

  it 'preserves the same token after persisting' do
    token = create(:token)
    value = token.value
    token.save!
    token.reload
    expect(token.value).to eql(value)
  end

  it 'will be valid with valid email address' do
    token = build(:token)
    expect(token).to be_valid
  end

  it 'will be invalid with invalid email address' do
    token = build(:token, user_email: 'bob')
    expect(token).not_to be_valid
  end

  it 'will be invalid with email address from wrong domain' do
    token = build(:token, user_email: 'bob@example.com')
    expect(token).not_to be_valid
  end

  describe '#for_person' do
    let(:person) { create(:person, email: 'text.user@digital.justice.gov.uk') }
    let(:token) { described_class.for_person(person) }

    it 'creates a token for that person\'s email' do
      expect(token.user_email).to eql(person.email)
    end
  end

  context 'time dependent tokens' do
    let(:active_token) { create(:token) }
    describe '#ttl' do
      it 'defaults to 10800 seconds (3 hours)' do
        expect(active_token.ttl).to eql(10_800)
      end
    end

    describe '#active?' do
      it 'returns true if token is less than 10800 seconds old and not spent' do
        expect(active_token).to be_active
        expect(active_token).to_not be_spent
      end

      it 'returns false if token is less than 10800 seconds old but already used' do
        spent_token = create(:token, spent: true)
        expect(spent_token).to_not be_active
      end

      it 'returns false if token is 10800 seconds or more old' do
        inactive_token = create(:token)
        Timecop.freeze(4.hours.from_now) do
          expect(inactive_token).to_not be_active
        end
      end

      context 'expiring tokens' do
        let(:person) { create(:person, email: 'text.user@digital.justice.gov.uk') }
        let(:old_token) { described_class.for_person(person) }

        describe '#save or #create for new tokens' do
          it 'deactivates previously created tokens for that user' do
            expect(old_token).to be_active
            new_token = described_class.for_person(person)
            old_token.reload
            new_token.reload
            expect(old_token).to_not be_active
            expect(new_token).to be_active
          end
        end

        describe "#spend!" do
          it 'sets spent to true and the token to inactive' do
            token = create(:token)
            expect(token).to be_active
            token.spend!
            expect(token.spent).to eql true
            expect(token).to_not be_active
          end
        end
      end
    end
  end

  context 'throttling token generation' do
    let(:person) { create(:person, email: 'text.user@digital.justice.gov.uk') }

    describe '#save or #create of a new token' do
      it 'throws and error if more than 8 tokens have been generated in the past hour for the same person' do
        1.upto(9) do |count|
          if count < 9
            expect { described_class.for_person(person) }.to_not raise_error
          else
            expect { described_class.for_person(person) }.to raise_error
          end
        end
      end
    end
  end
end
