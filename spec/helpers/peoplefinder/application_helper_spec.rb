require 'rails_helper'

RSpec.describe Peoplefinder::ApplicationHelper, type: :helper do
  before {
    helper.extend Peoplefinder::Engine.routes.url_helpers
  }

  let(:stubbed_time) { Time.new(2012, 10, 31, 2, 2, 2, "+01:00") }
  let(:originator) { Peoplefinder::Version.public_user }

  context '#last_update' do
    it 'shows last_update for a person by a system generated user' do
      @person = double(:person, updated_at: stubbed_time, originator: originator)
      expect(last_update).to eql('Last updated: 31 Oct 2012 02:02.')
    end

    it 'shows last_update for a person by someone who is not the system user' do
      @person = double(:person, updated_at: stubbed_time, originator: 'Bob')
      expect(last_update).to eql('Last updated: 31 Oct 2012 02:02 by Bob.')
    end

    it 'shows last_update for a group' do
      @group = double(:group, updated_at: stubbed_time, originator: originator)
      expect(last_update).to eql('Last updated: 31 Oct 2012 02:02.')
    end

    it 'does not show last_update for a new person' do
      @person = double(:group, updated_at: nil, originator: originator)
      expect(last_update).to be_blank
    end
  end

  context '#govspeak' do
    it 'renders Markdown starting from h3' do
      source = "# Header\n\nPara para"
      fragment = Capybara::Node::Simple.new(govspeak(source))

      expect(fragment).to have_selector('h3', text: 'Header')
    end
  end

  context '#breadcrumbs' do
    it 'builds linked breadcrumbs' do
      justice = create(:group, name: 'Justice')
      digital_service = create(:group, parent: justice, name: 'Digital Services')
      generated = breadcrumbs([justice, digital_service])
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="/teams/justice"]', text: 'Justice')
      expect(fragment).to have_selector('a[href="/teams/digital-services"]', text: 'Digital Services')
    end
  end
end
