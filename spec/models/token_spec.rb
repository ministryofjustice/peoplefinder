# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  value      :text
#  user_email :text
#  created_at :datetime
#  updated_at :datetime
#  spent      :boolean          default(FALSE)
#

require "rails_helper"

RSpec.describe Token, type: :model do
  include PermittedDomainHelper

  let(:token) { build(:token) }
  let(:person) { double(:person, email: "text.user@digital.justice.gov.uk") }

  it "generates a token" do
    expect(token.value).to match(/\A[a-z0-9-]{36}\z/)
  end

  it "preserves the same token after persisting" do
    expect {
      2.times { token.save }
      token.reload
    }.not_to change(token, :value)
  end

  it "will be valid with valid email address" do
    expect(token).to be_valid
  end

  it "will be invalid with invalid email address" do
    token.user_email = "bob"
    expect(token).not_to be_valid
  end

  it "will be invalid with email address from wrong domain" do
    token.user_email = "bob@example.com"
    expect(token).not_to be_valid
  end

  describe "create second token with same value as saved token" do
    let(:new_token) do
      described_class.new(user_email: token.user_email, value: token.value)
    end

    before do
      token.save!
      new_token.save!
    end

    it "sets spent true on previous token" do
      expect(token.reload.spent?).to eq true
    end

    it "allows new token to have the same value as original token" do
      expect(new_token.value).to eq token.value
    end
  end

  context "with scopes" do
    before do
      # Seems like a smell, but if I don't then it kills all the expired records
      # before the individual specs run.
      allow_any_instance_of(described_class).to receive(:remove_expired_tokens)
      token.save!
    end

    let!(:spent) { create(:token, spent: true) }
    let!(:half_hour_ago) { create(:token, created_at: 30.minutes.ago) }
    let!(:expired) { create(:token, created_at: 1.month.ago) }

    it ".spent" do
      expect(described_class.spent).to match_array([spent])
    end

    it ".unspent" do
      expect(described_class.unspent).to match_array([token, expired, half_hour_ago])
    end

    it ".unexpired" do
      expect(described_class.unexpired).to match_array([token, spent, half_hour_ago])
    end

    it ".expired" do
      expect(described_class.expired).to match_array([expired])
    end

    it ".in_the_last_hour" do
      expect(described_class.in_the_last_hour).to match_array([token, spent, half_hour_ago])
    end

    it ".find_unspent_by_user_email" do
      email = half_hour_ago.user_email
      unspent = described_class.find_unspent_by_user_email(email)
      expect(unspent).to eq(half_hour_ago)
    end

    describe ".find_securely" do
      it "uses constant-time comparison alogrithm to prevent timing attacks" do
        expect(Secure).to receive(:compare).at_least(:once)
        described_class.find_securely(spent.value)
      end

      it "returns first matching token" do
        token = described_class.find_securely(spent.value)
        expect(token).to eql spent
      end
    end
  end

  context "when creating a new token" do
    let!(:expiring_tokens) { create_list(:token, 3) }

    it "enqueues delayed job for destroying expired tokens" do
      expect { token.save }.to have_delayed_job 1
    end

    it "destroys expired tokens asynchronously for scalability" do
      expect { token.save }.to delay_method(:remove_expired_tokens)
    end

    context "when destroying all tokens older than the throttle limit" do
      before { Delayed::Worker.delay_jobs = false }

      after { Delayed::Worker.delay_jobs = true }

      it "destroys all expired tokens" do
        Timecop.travel(Time.zone.now + token.ttl) do
          expect { token.save }.to change { described_class.expired.count }.by(-3)
        end
      end
    end

    it "raises errors if a ttl is set to an hour or less" do
      expect(described_class).to receive(:ttl).and_return(60, 30, 1)
      expect { token.save }.to raise_error(Token::TTLRaceCondition)
      expect { token.save }.to raise_error(Token::TTLRaceCondition)
      expect { token.save }.to raise_error(Token::TTLRaceCondition)
    end
  end

  describe "#for_person" do
    let(:token) { described_class.for_person(person) }

    it "creates a token for that person's email" do
      expect(token.user_email).to eql(person.email)
    end
  end

  context "with time dependent tokens" do
    describe "#ttl" do
      it "defaults to 86400 seconds (24 hours)" do
        expect(token.ttl).to be(86_400)
      end
    end

    describe "#active?" do
      before do
        token.save!
        token.spend!
        token.reload
      end

      it "sets spent to true" do
        expect(token).to be_spent
      end

      it "returns true if token is spent but created less than 10 minutes ago" do
        Timecop.freeze(9.minutes.from_now) do
          expect(token).to be_active
        end
      end

      it "returns false if token is spent and created more than 10 minutes ago" do
        Timecop.freeze(11.minutes.from_now) do
          expect(token).not_to be_active
        end
      end

      context "with expiring tokens" do
        let(:expiring_token) { create(:token) }
        let(:new_token) { build(:token, user_email: expiring_token.user_email) }

        describe "#save or #create for new tokens" do
          it "removes previously created tokens for that user" do
            expect {
              new_token.save!
              expiring_token.reload
            }.to change(expiring_token, :spent?).from(false).to(true)
          end
        end
      end
    end
  end

  context "when throttling token generation" do
    describe "#save or #create of a new token" do
      it "throws and error if more than 8 tokens have been generated in the past hour for the same person" do
        8.times do
          expect(described_class.for_person(person)).to be_valid
        end
        expect { described_class.for_person(person) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
