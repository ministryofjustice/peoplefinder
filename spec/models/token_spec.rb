require 'rails_helper'

RSpec.describe Token, type: :model do
  include PermittedDomainHelper

  let(:token) { build(:token) }
  let(:person) { double(:person, email: 'text.user@digital.justice.gov.uk') }

  it 'generates a token' do
    expect(token.value).to match(/\A[a-z0-9\-]{36}\z/)
  end

  it 'preserves the same token after persisting' do
    expect do
      2.times { token.save }
      token.reload
    end.not_to change { token.value }
  end

  it 'will be valid with valid email address' do
    expect(token).to be_valid
  end

  it 'will be invalid with invalid email address' do
    token.user_email = 'bob'
    expect(token).not_to be_valid
  end

  it 'will be invalid with email address from wrong domain' do
    token.user_email = 'bob@example.com'
    expect(token).not_to be_valid
  end

  describe 'create second token with same value as saved token' do
    let(:new_token) do
      described_class.new(user_email: token.user_email, value: token.value)
    end

    before do
      token.save
      new_token.save!
    end

    it 'sets spent true on previous token' do
      expect(token.reload.spent?).to eq true
    end

    it 'allows new token to have the same value as original token' do
      expect(new_token.value).to eq token.value
    end
  end

  context 'scopes' do
    before do
      # Seems like a smell, but if I don't then it kills all the expired records
      # before the individual specs run.
      allow_any_instance_of(described_class).to receive(:remove_expired_tokens)
      token.save
    end

    let!(:spent) { create(:token, spent: true) }
    let!(:half_hour_ago) { create(:token, created_at: 30.minutes.ago) }
    let!(:expired) { create(:token, created_at: 1.month.ago) }

    it { expect(described_class.spent).to match_array([spent]) }
    it { expect(described_class.unspent).to match_array([token, expired, half_hour_ago]) }
    it { expect(described_class.unexpired).to match_array([token, spent, half_hour_ago]) }
    it { expect(described_class.expired).to match_array([expired]) }
    it { expect(described_class.in_the_last_hour).to match_array([token, spent, half_hour_ago]) }
  end

  context 'maintenance' do
    let!(:expiring_tokens) { create_list(:token, 3) }

    it 'removes expired tokens' do
      Timecop.travel(Time.now + token.ttl) do
        expect { token.save }.to change { described_class.expired.count }.by(-3)
      end
    end

    it 'raises errors if a ttl is set to an hour or less' do
      expect(described_class).to receive(:ttl).and_return(60, 30, 1)
      expect { token.save }.to raise_error(Token::TTLRaceCondition)
      expect { token.save }.to raise_error(Token::TTLRaceCondition)
      expect { token.save }.to raise_error(Token::TTLRaceCondition)
    end
  end

  describe '#for_person' do
    let(:token) { described_class.for_person(person) }

    it 'creates a token for that person\'s email' do
      expect(token.user_email).to eql(person.email)
    end
  end

  context 'time dependent tokens' do
    describe '#ttl' do
      it 'defaults to 10800 seconds (3 hours)' do
        expect(token.ttl).to eql(10_800)
      end
    end

    describe '#active?' do
      before { token.save }

      it 'returns true if token is less than 10800 seconds old and not spent' do
        expect(token.active?).to be_truthy
        expect(token.spent?).to be_falsey
      end

      it 'returns false if token is less than 10800 seconds old but already used' do
        expect do
          token.spend!
          token.reload
        end.to change { token.spent? }.from(false).to(true)
      end

      it 'returns false if token is 10800 seconds or more old' do
        Timecop.freeze(4.hours.from_now) do
          expect(token).not_to be_active
        end
      end

      context 'expiring tokens' do
        before { token.save }
        let(:new_token) { build(:token, user_email: token.user_email) }

        describe '#save or #create for new tokens' do
          it 'removes previously created tokens for that user' do
            expect do
              new_token.save
              token.reload
            end.to change { token.active? }.from(true).to(false)
          end
        end

        describe "#spend!" do
          it 'sets spent to true' do
            expect do
              token.spend!
              token.reload
            end.to change { token.spent? }.from(false).to(true)
          end

          it 'makes the token inactive' do
            expect do
              token.spend!
              token.reload
            end.to change { token.active? }.from(true).to(false)
          end
        end
      end
    end
  end

  context 'throttling token generation' do
    describe '#save or #create of a new token' do
      it 'throws and error if more than 8 tokens have been generated in the past hour for the same person' do
        8.times do
          expect(described_class.for_person(person)).to be_valid
        end
        expect { described_class.for_person(person) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
