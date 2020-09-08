require 'rails_helper'

RSpec.describe VersionsController, type: :controller do
  include PermittedDomainHelper

  describe '#index' do

    context 'readonly user' do
      before do
        mock_readonly_user
        get :index
      end

      it 'redirects to login' do
        expect(response).to redirect_to new_sessions_path
      end
    end

    context 'regular user' do
      before do
        mock_logged_in_user
        get :index
      end

      it 'redirects to home' do
        expect(response).to redirect_to home_path
      end
    end

    context 'for a super admin' do
      before do
        mock_logged_in_user super_admin: true
        get :index
      end

      it 'redirects to login' do
        expect(response).to render_template :index
      end
    end

  end

  describe '.undo' do
    before do
      mock_logged_in_user super_admin: true
    end

    it 'undoes a new person - by deleting it' do
      with_versioning do
        person = create(:person)
        version = PaperTrail::Version.where(item_type: 'Person').last
        put :undo, params: { id: version.id }

        expect { Person.find(person.id) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'undoes a deleted person - by renewing it' do
      with_versioning do
        person = create(:person, surname: 'Necro')
        person.destroy
        version = PaperTrail::Version.where(item_type: 'Person').last
        put :undo, params: { id: version.id }

        expect(Person.find_by_surname('Necro')).to be_present
      end
    end

    it 'does not undo a new membership' do
      with_versioning do
        membership = create(:membership)
        version = PaperTrail::Version.last
        put :undo, params: { id: version.id }

        expect(Membership.find(membership.id)).to be_present
      end
    end

    it 'does not undo a deleted membership' do
      with_versioning do
        membership = create(:membership)
        membership.destroy
        version = PaperTrail::Version.last
        put :undo, params: { id: version.id }

        expect { Membership.find(membership.id) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
