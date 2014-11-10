require 'rails_helper'
include ApplicationHelper

describe ApplicationHelper do
  context 'govspeak' do
    it 'converts text to html' do
      source = "text\n\nmore text"
      expect(govspeak(source)).
        to match(%r{<p>\s*text\s*</p>\s*<p>\s*more text\s*</p>})
    end

    it 'does not pass through arbitrary script' do
      source = "<script>alert('pwned')</script>"
      expect(govspeak(source)).
        not_to match(/<script/)
    end

    it 'tags the string as html safe after sanitising' do
      expect(govspeak('')).to be_html_safe
    end
  end
end
