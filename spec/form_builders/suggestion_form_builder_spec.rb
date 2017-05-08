require 'rails_helper'

RSpec.describe SuggestionFormBuilder, type: :form_builder do

  let(:object) { Object.new }
  let(:template) { ActionView::Base.new }
  let(:options) { {} }
  let(:builder) { described_class.new(:suggestion, object, template, options) }

  # patch String#strip_heredoc to remove whitespace resulting from line breaks
  class String
    def squish_heredoc
      squish.gsub(/\s*</, "<").gsub(/>\s*/, ">").strip_heredoc
    end
  end

  describe '#check_box' do
    subject { builder.check_box(:test_field) }

    before do
      I18n.backend.store_translations(
        :en,
        helpers: {
          label: {
            suggestion: {
              test_field: 'My test label'
            }
          }
        }
      )
    end

    let(:output) do
      <<~HTML.squish_heredoc
      <div class="form-group">
        <label class="block-label selection-button-checkbox" for="suggestion_test_field">
          <input name="suggestion[test_field]" type="hidden" value="0" />
          <input type="checkbox" value="1" name="suggestion[test_field]" id="suggestion_test_field" />
          My test label
        </label>
      </div>
      HTML
    end

    it 'returns govuk styled check box' do
      is_expected.to eql output
    end

    it 'adds outer form-group div' do
      is_expected.to match(/<div class="form-group">.*<\/div>/)
    end

    it 'adds a selectable block-label inside the form-group' do
      is_expected.to match(/.*form-group.*<label class="block-label selection-button-checkbox" for="suggestion_test_field">.*<\/label>/)
    end

    it 'adds a checkbox inside the label' do
      is_expected.to match(/<label.*<input type="checkbox" value="1" name="suggestion\[test_field\]" id="suggestion_test_field" \/>.*<\/label>/)
    end

    it 'adds label from translation defined in specific scope' do
      is_expected.to include 'My test label'
    end

  end

end
