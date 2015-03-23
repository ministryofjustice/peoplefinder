require 'spec_helper'
require 'peoplefinder/mark_mandatory_labels'

describe Peoplefinder::MarkMandatoryLabels do
  let(:object) { double }
  let(:form_builder) { double(object: object, label: nil) }
  subject { described_class.new(form_builder) }
  let(:block) { proc {} }

  context 'when the object does not respond to mandates_presence_of?' do
    it 'does not call mandates_presence_of? on the object' do
      expect(double).not_to receive(:mandates_presence_of?)
      subject.label(:field)
    end

    it 'delegates label to form builder with the same arguments' do
      expect(form_builder).to receive(:label).
        with(:field, 'text', foo: 'bar', &block)
      subject.label(:field, 'text', foo: 'bar', &block)
    end
  end

  context 'when the field is mandatory' do
    before do
      allow(object).to receive(:mandates_presence_of?).
        with(:field).and_return(true)
    end

    it 'delegates label to the form builder with the arguments passed in' do
      expect(form_builder).to receive(:label).
        with(:field, 'text', a_hash_including(foo: 'bar'), &block)
      subject.label(:field, 'text', foo: 'bar', &block)
    end

    it 'adds a mandatory class' do
      expect(form_builder).to receive(:label).
        with(anything, anything, foo: 'bar', class: 'mandatory')
      subject.label(:field, 'text', foo: 'bar')
    end

    it 'adds mandatory to the existing class' do
      expect(form_builder).to receive(:label).
        with(anything, anything, class: 'foo mandatory')
      subject.label(:field, 'text', class: 'foo')
    end

    it 'copies the Rails hand-rolled polymorphic method dispatch' do
      expect(form_builder).to receive(:label).
        with(anything, nil, foo: 'bar', class: 'mandatory')
      subject.label(:field, foo: 'bar')
    end
  end

  context 'when the field is optional' do
    before do
      allow(object).to receive(:mandates_presence_of?).
        with(:field).and_return(false)
    end

    it 'delegates label to the form builder as-is' do
      expect(form_builder).to receive(:label).
        with(:field, 'text', foo: 'bar', &block)
      subject.label(:field, 'text', foo: 'bar', &block)
    end

    it 'copies the Rails hand-rolled polymorphic method dispatch' do
      expect(form_builder).to receive(:label).
        with(anything, nil, foo: 'bar')
      subject.label(:field, foo: 'bar')
    end
  end
end
