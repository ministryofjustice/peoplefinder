require 'spec_helper'
# require 'form_groups'
require_relative '../../app/form_builders/form_groups'

describe FormGroups do
  let(:object) { double(errors: []) }
  let(:template) { double(content_tag: nil) }
  let(:form_builder) { double(object: object, template: template) }
  subject { described_class.new(form_builder) }
  let(:block) { proc {} }

  context 'when the object does not respond to needed_for_completion?' do
    it 'does not call needed_for_completion? on the object' do
      expect(double).not_to receive(:needed_for_completion?)
      subject.form_group(:field)
    end

    it 'delegates to the template to build a form-group div' do
      expect(template).to receive(:content_tag).
        with(:div, class: 'form-group', &block)
      subject.form_group(:field)
    end
  end

  context 'when the field is needed for completion' do
    before do
      allow(object).to receive(:needed_for_completion?).
        with(:field).and_return(true)
    end

    it 'builds an incomplete form-group div' do
      expect(template).to receive(:content_tag).
        with(:div, class: 'form-group incomplete', &block)
      subject.form_group(:field)
    end

    it 'builds an incomplete form-group div with custom classes' do
      expect(template).to receive(:content_tag).
        with(:div, class: 'foo form-group incomplete', &block)
      subject.form_group(:field, class: 'foo')
    end
  end

  context 'when the field has an error' do
    before do
      allow(object).to receive(:needed_for_completion?).
        with(:field).and_return(false)
      allow(object).to receive(:errors).and_return([:field])
    end

    it 'builds an error form-group div' do
      expect(template).to receive(:content_tag).
        with(:div, class: 'form-group gov-uk-field-error', &block)
      subject.form_group(:field)
    end
  end

  context 'when the field has an error and is needed for completion' do
    before do
      allow(object).to receive(:needed_for_completion?).
        with(:field).and_return(true)
      allow(object).to receive(:errors).and_return([:field])
    end

    it 'builds an error form-group div' do
      expect(template).to receive(:content_tag).
        with(:div, class: 'form-group gov-uk-field-error', &block)
      subject.form_group(:field)
    end
  end
end
