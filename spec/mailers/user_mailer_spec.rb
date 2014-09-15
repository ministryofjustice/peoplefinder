require 'rails_helper'

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe 'introduction email' do
    let!(:alice) { create(:user) }
    let!(:bob) { create(:user, manager: alice) }
    let!(:charlie) { create(:user, manager: bob) }
    let(:token) { create(:token, user: user) }
    let(:email) { described_class.introduction(user, token) }

    describe 'for everybody' do
      let(:user) { bob }

      it 'contains a token link' do
        expect(email).to have_body_text(token_url(token))
      end

      it 'has the correct subject' do
        expect(email).to have_subject('360 feedback process has begun')
      end
    end

    describe 'for Alice, a top-tier person' do
      let(:user) { alice }

      it 'only mentions relevant features' do
        expect(email).to have_body_text('Request feedback on your direct reports')
        expect(email).to have_body_text('Monitor progress of feedback requests')
        expect(email).not_to have_body_text('Ask for feedback on your performance')
        expect(email).not_to have_body_text('View feedback on yourself')
      end
    end

    describe 'for Bob, a middle-tier person' do
      let(:user) { bob }

      it 'mentions all relevant features' do
        expect(email).to have_body_text('Request feedback on your direct reports')
        expect(email).to have_body_text('Monitor progress of feedback requests')
        expect(email).to have_body_text('Ask for feedback on your performance')
        expect(email).to have_body_text('View feedback on yourself')
      end
    end

    describe 'for Charlie, a bottom-tier person' do
      let(:user) { charlie }

      it 'only mentions relevant features' do
        expect(email).not_to have_body_text('Request feedback on your direct reports')
        expect(email).to have_body_text('Monitor progress of feedback requests')
        expect(email).to have_body_text('Ask for feedback on your performance')
        expect(email).to have_body_text('View feedback on yourself')
      end
    end
  end
end
