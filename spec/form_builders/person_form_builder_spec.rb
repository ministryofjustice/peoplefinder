require "rails_helper"

# patch String#strip_heredoc to remove whitespace resulting from line breaks
class String
  def squish_heredoc
    squish.gsub(/\s*</, "<").gsub(/>\s*/, ">").strip_heredoc
  end
end

RSpec.describe PersonFormBuilder, type: :form_builder do
  let(:object) { Object.new }
  let(:template) { ActionView::Base.new({}, {}, nil) }
  let(:options) { {} }
  let(:builder) { described_class.new(:person, object, template, options) }

  describe "#check_box" do
    subject(:check_box) { builder.check_box(:works_monday) }

    before do
      I18n.backend.store_translations(
        :en,
        helpers: {
          label: {
            person: {
              works_monday: "Monday",
            },
          },
        },
      )
    end

    let(:output) do
      <<~HTML.squish_heredoc
        <div class="form-group">
          <label class="block-label selection-button-checkbox" for="person_works_monday">
            <input name="person[works_monday]" type="hidden" value="0" autocomplete="off" />
            <input type="checkbox" value="1" name="person[works_monday]" id="person_works_monday" />
            Monday
          </label>
        </div>
      HTML
    end

    it "returns govuk styled check box" do
      expect(check_box).to match output
    end

    it "adds outer form-group div" do
      expect(check_box).to match(/<div class="form-group">.*<\/div>/)
    end

    it "adds a selectable block-label inside the form-group" do
      expect(check_box).to match(/.*form-group.*<label class="block-label selection-button-checkbox" for="person_works_monday">.*<\/label>/)
    end

    it "adds a checkbox inside the label" do
      expect(check_box).to match(/<label.*<input type="checkbox" value="1" name="person\[works_monday\]" id="person_works_monday" \/>.*<\/label>/)
    end

    it "adds label from translation defined in specific scope" do
      expect(check_box).to include "Monday"
    end
  end

  describe "#text_field" do
    subject(:text_field) { builder.text_field(:test_field) }

    before do
      I18n.backend.store_translations(:en, translations)
      allow(object).to receive(:test_field)
      allow(object).to receive(:needed_for_completion?).and_return true
      allow(object).to receive(:class).and_return Person
    end

    let(:object) { double("person") } # rubocop:disable RSpec/VerifiedDoubles

    let(:translations) do
      {
        helpers: {
          label: {
            person: {
              test_field: "Test label",
            },
          },
          hint: {
            person: {
              test_field: "Test hint",
            },
          },
        },
      }
    end

    let(:output) do
      <<~HTML.squish_heredoc
        <div class=\"form-group\">
          <label class=\"form-label\" for=\"person_test_field\">
            Test label
            <span class="form-hint">Test hint</span>
          </label>
          <input class=\"form-control incomplete\" type=\"text\" name=\"person[test_field]\" id=\"person_test_field\" />
        </div>
      HTML
    end

    it "adds profile completion class to field if needed" do
      expect(text_field).to include "incomplete"
    end

    it "does NOT add profile completion class to field if NOT needed" do
      allow(object).to receive(:needed_for_completion?).and_return false
      expect(text_field).not_to include "incomplete"
    end

    it "returns govuk styled text field" do
      expect(text_field).to eql output
    end
  end
end
