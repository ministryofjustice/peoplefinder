require 'rails_helper'

RSpec.describe Login, type: :service do
  include PermittedDomainHelper

  let(:session) { {} }
  let(:person) { create(:person) }
  subject(:service) { described_class.new(session, person) }

  describe '#login' do
    let(:current_time) { Time.now }
    subject { service.login }

    it 'increments login count' do
      expect { subject }.to change { person.login_count }.by(1)
    end
    it 'stores the current time of login' do
      Timecop.freeze(current_time) do
        expect { subject }.to change { person.last_login_at }.to(current_time)
      end
    end
    it 'stores the person id in the session' do
      expect { subject }.to change { session[Login::SESSION_KEY] }.from(nil).to(person.id)
    end
  end

  describe '#logout' do
    subject { service.logout }
    before do
      session[Login::SESSION_KEY] = person.id
    end

    it 'removes the person id from the session' do
      expect { subject }.to change { session[Login::SESSION_KEY] }.to(nil)
    end
  end

  describe '.current_user' do
    subject { described_class.current_user(session) }

    before do
      session[Login::SESSION_KEY] = person_id
    end

    context 'when user is logged in' do
      let(:person_id) { person.id }

      it 'returns the currently logged in person' do
        expect(subject).to eql(person)
      end
    end

    context 'when user is not logged in' do
      let(:person_id) { nil }

      it { is_expected.to be nil }
    end

    context 'when user seem to be logged in, but does not exist' do
      let(:person_id) { 'invalid' }

      it 'raises ActiveRecord::RecordNotFound error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
