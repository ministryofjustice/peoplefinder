require "rails_helper"

RSpec.describe Login, type: :service do
  include PermittedDomainHelper

  let(:service) { described_class.new(session, person) }

  let(:session) { {} }
  let(:person) { create(:person) }

  describe "#login" do
    before do
      session[Login::KEY_TYPE] = "person"
    end

    subject(:login) { service.login }

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

    it "stores the person id in the session" do
      expect { login }.to change { session[Login::SESSION_KEY] }.from(nil).to(person.id)
    end
  end

  describe "#logout" do
    before do
      session[Login::KEY_TYPE] = "person"
      session[Login::SESSION_KEY] = person.id
    end

    it "removes the person id from the session" do
      expect { service.logout }.to change { session[Login::SESSION_KEY] }.to(nil)
    end
  end

  describe ".current_user" do
    subject(:current_user) { described_class.current_user(session) }

    before do
      session[Login::KEY_TYPE] = "person"
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

      it { is_expected.to be nil }
    end

    context "when user seem to be logged in, but does not exist" do
      let(:person_id) { "invalid" }

      it "raises ActiveRecord::RecordNotFound error" do
        expect { current_user }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
