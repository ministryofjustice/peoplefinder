require 'rails_helper'

RSpec.describe Peoplefinder::Concerns::Placeholder do

  class TestModel
    extend ActiveModel::Naming
    include Peoplefinder::Concerns::Placeholder
    attr_accessor :field
  end

  subject { TestModel.new }

  describe '#placeholder' do
    it 'looks up placeholder text via I18n' do
      expect(subject.placeholder(:field)).
        to eq('translation missing: en.placeholders.test_model.field')
    end
  end

  describe '#with_placeholder_default' do
    it 'returns the value of a field if present' do
      subject.field = 'EXAMPLE TEXT'
      expect(subject.with_placeholder_default(:field)).
        to eq('EXAMPLE TEXT')
    end

    it 'returns the placeholder text if field is blank' do
      subject.field = ''
      expect(subject.with_placeholder_default(:field)).
        to eq('translation missing: en.placeholders.test_model.field')
    end
  end
end
