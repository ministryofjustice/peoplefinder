require 'rails_helper'

RSpec.describe PeopleHelper, type: :helper do
  include PermittedDomainHelper

  describe 'day_name' do
    it "returns a name for each day" do
      expect(day_name(:works_wednesday)).to eql("Wednesday")
    end

    it "returns a symbol for each day" do
      expect(day_symbol(:works_wednesday)).to eql("W")
    end
  end

  describe 'person_form_class' do
    let(:person) { double(Person, new_record?: false) }

    it 'includes "new_person" if person is a new record' do
      allow(person).to receive(:new_record?).and_return(true)
      expect(person_form_class(person, nil)).to match(/\bnew_person\b/)
    end

    it 'includes "edit_person" if person is not a new record' do
      allow(person).to receive(:new_record?).and_return(false)
      expect(person_form_class(person, nil)).to match(/\bedit_person\b/)
    end

    it 'does not include "completing" if activity is not "complete"' do
      expect(person_form_class(person, nil)).not_to match(/\bcompleting\b/)
    end

    it 'includes "completing" if activity is "complete"' do
      expect(person_form_class(person, 'complete')).to match(/\bcompleting\b/)
    end
  end

  describe 'profile_image_tag' do
    let(:person)  { create(:person, :with_photo) }
    let(:options) { { class: 'my-class', version: :croppable } }

    it 'test builds person with photo' do
      expect(person.profile_photo.image).not_to be_nil
    end

    it 'adds a link to the person profile by default' do
      expect(profile_image_tag(person, options)).to match(/.*href=\"\/people\/.*\".*/)
    end

    it 'does not add a link to when option set' do
      expect(profile_image_tag(person, options.merge(link: false))).to_not match(/.*href=.*/)
    end

    it 'uses the specified image version' do
      expect(profile_image_tag(person, options)).to match(/.*profile_photo.*\/croppable.*/)
    end

    it 'removes the version element from options hash' do
      expect { profile_image_tag(person, options) }.to change { options.keys }.from([:class, :version]).to([:class, :link])
    end

    it 'defaults to using the medium image version' do
      options.delete(:version)
      expect(profile_image_tag(person, options)).to match(/.*profile_photo.*\/medium_.*/)
    end

    it 'fallsback to using medium_no_photo.png' do
      person.profile_photo_id = nil
      expect(profile_image_tag(person, options)).to match(/.*\/medium_no_photo.png.*/)
    end
  end

  describe 'edit_person_link' do
    include AnalyticsHelper

    let(:person) { create :person, slug: 'fred-bloggs' }

    it 'builds an anchor tag reference to edit page for the person' do
      expect(edit_person_link('Edit profile', person)).to match(/href=\"\/people\/fred-bloggs\/edit\"/)
    end

    it 'inserts activity option as url param' do
      expect(edit_person_link('Edit profile', person, activity: 'complete')).to include '?activity=complete'
    end

    it 'sends message to contruct google analytics attributes' do
      expect(self).to receive(:edit_profile_analytics_attributes).with(person.id)
      edit_person_link('Edit profile', person)
    end
  end

end
