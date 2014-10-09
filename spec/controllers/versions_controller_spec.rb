require 'rails_helper'

RSpec.describe Peoplefinder::VersionsController, type: :controller do
  routes { Peoplefinder::Engine.routes }

  before do
    mock_logged_in_user
  end

  describe '.undo' do
    it 'undoes a new person - by deleting it' do
      with_versioning do
        person = create(:person)
        version = PaperTrail::Version.last
        put :undo, id: version.id

        expect { Peoplefinder::Person.find(person) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'undoes a deleted person - by renewing it' do
      with_versioning do
        person = create(:person, surname: 'Necro')
        person.destroy
        version = PaperTrail::Version.last
        put :undo, id: version.id

        expect(Peoplefinder::Person.find_by_surname('Necro')).to be_present
      end
    end

    it 'does not undo a new membership' do
      with_versioning do
        membership = create(:membership)
        version = PaperTrail::Version.last
        put :undo, id: version.id

        expect(Peoplefinder::Membership.find(membership)).to be_present
      end
    end

    it 'does not undo a deleted membership' do
      with_versioning do
        membership = create(:membership)
        membership.destroy
        version = PaperTrail::Version.last
        put :undo, id: version.id

        expect { Peoplefinder::Membership.find(membership) }.
          to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
