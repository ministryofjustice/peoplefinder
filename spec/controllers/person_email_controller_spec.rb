require 'rails_helper'

RSpec.describe PersonEmailController, type: :controller do
  include PermittedDomainHelper

  let(:valid_attributes) do
    attributes_for(:person)
  end

  let(:invalid_attributes) do
    { surname: '' }
  end

  describe 'GET edit' do
    let(:person) { create(:person, valid_attributes) }
    let(:new_email) { 'my-new-email@digital.justice.gov.uk' }

    before do
      get :edit, person_id: person.to_param, new_email: new_email
    end

    it 'assigns the requested person as @person' do
      expect(assigns(:person)).to eq(person)
    end

    it 'assigns existing email as @new_email' do
      expect(assigns(:new_email)).to eq(new_email)
    end

    it 'assigns existing primary email as @new_secondary_email' do
      expect(assigns(:new_secondary_email)).to eq(person.email)
    end

    it { expect(response).to render_template :edit }
  end

  describe 'PUT update' do
    let(:person) { create(:person, given_name: "John", surname: "Doe", email: 'john.doe@digital.justice.gov.uk') }
    let(:new_attributes) { { email: 'john.doe2@digital.justice.gov.uk', secondary_email: 'john.doe@digital.justice.gov.uk', pager_number: '0100' } }
    subject do
      put :update, person_id: person.to_param, person: new_attributes
    end

    it 'assigns person' do
      subject
      expect(assigns(:person)).to eql person
    end

    it 'updates email and secondary email only' do
      subject
      person.reload
      expect(person.email).to eql new_attributes[:email]
      expect(person.secondary_email).to eql new_attributes[:secondary_email]
      expect(person.pager_number).not_to eql new_attributes[:pager_number]
    end

    it 'redirects to profile page, ignoring desired path' do
      request.session[:desired_path] = new_group_path
      is_expected.to redirect_to person_path(person, prompt: 'profile')
    end

    it 'sets a flash message' do
      subject
      expect(flash[:notice]).to include("Your primary email has been updated to #{new_attributes[:email]}")
    end
  end

end
