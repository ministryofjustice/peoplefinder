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
    before do
      @last_updated_at = stubbed_time
    end

    it 'shows last_update for a person by a system generated user' do
      @person = double(:person, paper_trail_originator: originator)
      expect(last_update).to eql('Last updated: 31 Oct 2012 02:02.')
    end

    it 'shows last_update for a person by someone who is not the system user' do
      @person = double(:person, paper_trail_originator: 'Bob')
      expect(last_update).to eql('Last updated: 31 Oct 2012 02:02 by Bob.')
    end

    it 'shows last_update for a group' do
      @group = double(:group, paper_trail_originator: originator)
      expect(last_update).to eql('Last updated: 31 Oct 2012 02:02.')
    end

    it 'does not show last_update for a new person' do
      @person = double(:group, paper_trail_originator: originator)
      @last_updated_at = nil
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

  describe '#bold_tag' do
    subject { bold_tag('bold text', options) }

    let(:options) { {} }

    it 'applies span around the term' do
      is_expected.to have_selector('span', text: 'bold text')
    end

    it 'applies bold-term class to span around the term' do
      is_expected.to have_selector('span.bold-term', text: 'bold text')
    end

    it 'appends bold-term to other classes passed in' do
      options[:class] = 'my-other-class'
      is_expected.to include('bold-term', 'my-other-class')
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
end
