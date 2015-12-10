require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:stubbed_time) { Time.new(2012, 10, 31, 2, 2, 2, "+01:00") }
  let(:originator) { Version.public_user }

  describe '#pluralize_with_delimiter' do
    it 'handles singular correctly' do
      expect(pluralize_with_delimiter(1, 'person')).to eq '1 person'
    end

    it 'handles plural correctly' do
      expect(pluralize_with_delimiter(2000, 'person')).to eq '2,000 people'
    end
  end

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

  context '#call_to' do
    it 'returns an a with a tel: href' do
      generated = call_to('07700900123')
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:07700900123"]', text: '07700900123')
    end

    it 'strips extraneous characters from href' do
      generated = call_to('07700 900 123')
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:07700900123"]')
    end

    it 'preserves significant non-numeric characters in href' do
      generated = call_to('+447700900123,,1234#*')
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:+447700900123,,1234#*"]')
    end

    it 'returns nil if telephone number is nil' do
      expect(call_to(nil)).to be_nil
    end
  end

  context '#role_translate' do
    let(:current_user) { build(:person) }

    it 'uses the "mine" translation when the user is the current user' do
      expect(I18n).to receive(:t).
        with('foo.bar.mine', hash_including(name: current_user)).
        and_return('translation')
      expect(role_translate(current_user, 'foo.bar')).to eq('translation')
    end

    it 'uses the "other" translation when the user is not the current user' do
      expect(I18n).to receive(:t).
        with('foo.bar.other', hash_including(name: current_user)).
        and_return('translation')
      expect(role_translate(build(:person), 'foo.bar')).to eq('translation')
    end
  end

  describe '#link_to_short_name_unless_current' do
    context 'with an object that has a short name' do
      let(:obj) { double('obj', name: 'Full Name', short_name: 'FN') }

      it 'links to the object' do
        expect(self).to receive(:link_to_unless_current).
          with(anything, obj, anything)
        link_to_short_name_unless_current(obj)
      end

      it 'uses the short name for the link text' do
        expect(self).to receive(:link_to_unless_current).
          with('FN', anything, anything)
        link_to_short_name_unless_current(obj)
      end

      it 'uses the name for the link title' do
        expect(self).to receive(:link_to_unless_current).
          with(anything, anything, title: 'Full Name')
        link_to_short_name_unless_current(obj)
      end
    end

    context 'with an object that has an empty short name' do
      let(:obj) { double('object', name: 'Full Name', short_name: '') }

      it 'links to the object' do
        expect(self).to receive(:link_to_unless_current).
          with(anything, obj, anything)
        link_to_short_name_unless_current(obj)
      end

      it 'uses the name for the link text' do
        expect(self).to receive(:link_to_unless_current).
          with('Full Name', anything, anything)
        link_to_short_name_unless_current(obj)
      end

      it 'has no link title' do
        expect(self).to receive(:link_to_unless_current).
          with(anything, anything, {})
        link_to_short_name_unless_current(obj)
      end
    end

    context 'with an object that has no short name' do
      let(:obj) { double('object', name: 'Full Name') }

      it 'links to the object' do
        expect(self).to receive(:link_to_unless_current).
          with(anything, obj, anything)
        link_to_short_name_unless_current(obj)
      end

      it 'uses the name for the link text' do
        expect(self).to receive(:link_to_unless_current).
          with('Full Name', anything, anything)
        link_to_short_name_unless_current(obj)
      end

      it 'has no link title' do
        expect(self).to receive(:link_to_unless_current).
          with(anything, anything, {})
        link_to_short_name_unless_current(obj)
      end
    end
  end
end
