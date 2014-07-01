require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  let(:stubbed_time) { Time.new(2012, 10, 31, 2, 2, 2, "+01:00") }

  context '#last_update' do
    it 'should show last_update for a person' do
      @person = double(:person, updated_at: stubbed_time)
      expect(last_update).to eql('Last updated: 31 Oct 2012.')
    end

    it 'should show last_update for a group' do
      @group = double(:group, updated_at: stubbed_time)
      expect(last_update).to eql('Last updated: 31 Oct 2012.')
    end

    it 'should not show last_update for a new person' do
      @person = double(:group, updated_at: nil)
      expect(last_update).to be_blank
    end
  end

  context '#govspeak' do
    it 'should render Markdown starting from h3' do
      source = "# Header\n\nPara para"
      fragment = Capybara::Node::Simple.new(govspeak(source))

      expect(fragment).to have_selector('h3', text: 'Header')
    end
  end

  context '#body_class' do
    it 'should set the body_class' do
      expect(body_class).to eql(Rails.configuration.phase + " " + Rails.configuration.product_type)
    end
  end

  context '#breadcrumbs' do
    it 'should return group breadcrumbs' do
      justice = create(:group, name: 'Justice')
      digital_service = create(:group, parent: justice, name: 'Digital Services')
      fragment = Capybara::Node::Simple.new(group_breadcrumbs(digital_service))
      expect(fragment).to have_selector('a[href="/groups/justice"]', text: 'Justice')
      expect(fragment).to have_selector('a[href="/groups/digital-services"]', text: 'Digital Services')
    end
  end
end
