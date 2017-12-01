require 'rails_helper'

describe 'Person Profile API', type: :request do
  include PermittedDomainHelper

  let(:parsed_json) { JSON.parse(response.body).with_indifferent_access }
  let(:attr_hash) { parsed_json['data']['attributes'] }
  let(:links_hash) { parsed_json['data']['links'] }
  let(:profile_image_url_hash_key) { 'profile-image-url' }

  before do
    get "/api/people?email=#{person.email}", {},
      authorization: "Token #{ENV['PROFILE_API_TOKEN']}"
  end

  context 'in general' do
    let(:person) { create(:person, :with_photo, :team_member) }

    it 'has the expected person attributes' do
      expect(attr_hash).to have_key('email')
      expect(attr_hash).to have_key('name')
      expect(attr_hash).to have_key('completion-score')
    end

    it 'has the team' do
      expect(attr_hash['team']).to eq(person.memberships[0].to_s)
    end

    it 'has the profile link' do
      expect(links_hash['profile']).to eq(person_url(person))
    end

    it 'has the edit-profile link' do
      expect(links_hash['edit-profile']).to eq(edit_person_url(person))
    end

    it 'has the profile-image-url' do
      expect(links_hash[profile_image_url_hash_key]).to match(
        /small_profile_photo_valid.png/
      )
    end
  end

  context 'with no profile image' do
    let(:person) { create(:person) }

    it 'does not have the profile-image-url' do
      expect(links_hash[profile_image_url_hash_key]).to be_blank
    end
  end

  context 'when the person is found by the AuthUserLoader', auth_user_loader: true do
    let(:person) { create(:person, internal_auth_key: 'auth_user@example.com') }

    it { expect(attr_hash['email']).to eq(person.email) }
  end

  context 'when the person is not found by the AuthUserLoader', auth_user_loader: true do
    let(:person) { double(:person, email: 'nobody@example.com') }

    it 'returns a 404' do
      expect(response.status).to eq(404)
    end
  end
end
