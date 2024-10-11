require "rails_helper"

RSpec.describe Login, type: :service do
  include PermittedDomainHelper

  let(:service) { described_class.new(session, person) }
  let(:person) { create(:person) }
  let(:session) { {} }

  describe "#login" do
    subject(:login) { service.login }

    context "when an Moj user logs in" do
      let(:current_time) { Time.zone.now }

      it "increments login count" do
        expect { login }.to change(person, :login_count).by(1)
      end

      it "stores the current time of login" do
        Timecop.freeze(current_time) do
          expect { login }.to change(person, :last_login_at)
          expect(person.last_login_at.change(usec: 0)).to eq(current_time.change(usec: 0))
        end
      end

      it "changes the session key" do
        expect { login }.to change { session[Login::SESSION_KEY] }.from(nil).to(person.id)
      end

      it "changes the type key" do
        expect { login }.to change { session[Login::TYPE_KEY] }.from(nil).to("person")
      end
    end

    context "when an External user logs in" do
      let(:person) { create(:external_user) }

      it "changes the session key changes" do
        expect { login }.to change { session[Login::SESSION_KEY] }.from(nil).to(person.id)
      end

      it "changes the session type key" do
        expect { login }.to change { session[Login::TYPE_KEY] }.from(nil).to("external_user")
      end
    end

    context "when the user is invalid" do
      let(:person) { create(:token) }

      it "leaves the session key unchanged" do
        expect { login }.not_to change { session[Login::SESSION_KEY] }.from(nil)
      end

      it "leaves the type key unchanged" do
        expect { login }.not_to change { session[Login::TYPE_KEY] }.from(nil)
      end
    end
  end

  describe "#logout" do
    before do
      session[Login::TYPE_KEY] = "person"
      session[Login::SESSION_KEY] = person.id
    end

    it "removes the person id from the session" do
      expect { service.logout }.to change { session[Login::SESSION_KEY] }.to(nil)
    end
  end

  describe ".current_user" do
    subject(:current_user) { described_class.current_user(session) }

    before do
      session[Login::TYPE_KEY] = "person"
      session[Login::SESSION_KEY] = person_id
    end

    context "when user is logged in" do
      let(:person_id) { person.id }

      it "returns the currently logged in person" do
        expect(current_user).to eql(person)
      end
    end

    context "when user is not logged in" do
      let(:person_id) { nil }

      it { is_expected.to be_nil }
    end

    context "when user seem to be logged in, but does not exist" do
      let(:person_id) { "invalid" }

      it "raises ActiveRecord::RecordNotFound error" do
        expect { current_user }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
