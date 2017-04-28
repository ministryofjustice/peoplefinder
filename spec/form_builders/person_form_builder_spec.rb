require 'rails_helper'

RSpec.describe PersonFormBuilder, type: :form_builder do

  let(:object) { Object.new }
  let(:template) { ActionView::Base.new }
  let(:options) { {} }
  let(:builder) { described_class.new(:person, object, template, options) }

  # patch String#strip_heredoc to remove whitespace resulting from line breaks
  class String
    def squish_heredoc
      squish.gsub(/\s*</, "<").gsub(/>\s*/, ">").strip_heredoc
    end
  end

  describe '#check_box' do
    subject { builder.check_box(:works_monday) }

    before do
      I18n.backend.store_translations(
        :en,
        helpers: {
          label: {
            person: {
              works_monday: 'Monday'
            }
          }
        }
      )
    end

    let(:output) do
      <<~HTML.squish_heredoc
      <div class="form-group">
        <label class="block-label selection-button-checkbox" for="person_works_monday">
          <input name="person[works_monday]" type="hidden" value="0" />
          <input type="checkbox" value="1" name="person[works_monday]" id="person_works_monday" />
          Monday
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
      is_expected.to match(/.*form-group.*<label class="block-label selection-button-checkbox" for="person_works_monday">.*<\/label>/)
    end

    it 'adds a checkbox inside the label' do
      is_expected.to match(/<label.*<input type="checkbox" value="1" name="person\[works_monday\]" id="person_works_monday" \/>.*<\/label>/)
    end

    it 'adds label from translation defined in specific scope' do
      is_expected.to include 'Monday'
    end

  end

  describe '#text_field' do
    let(:object) { double 'object' }
    subject { builder.text_field(:test_field) }

    let(:output) do
      <<~HTML.squish_heredoc
        <div class=\"form-group\">
          <label class=\"form-label\" for=\"person_test_field\">
            Test field
          </label>
          <input class=\"form-control incomplete\" type=\"text\" name=\"person[test_field]\" id=\"person_test_field\" />
        </div>
      HTML
    end

    before do
      allow(object).to receive(:test_field)
      allow(object).to receive(:needed_for_completion?).and_return true
    end

    it 'adds profile completion class to field if needed' do
      is_expected.to include 'incomplete'
    end

    it 'does NOT add profile completion class to field if NOT needed' do
      allow(object).to receive(:needed_for_completion?).and_return false
      is_expected.not_to include 'incomplete'
    end

    it 'returns govuk styled text field' do
      is_expected.to eql output
    end
  end

end
