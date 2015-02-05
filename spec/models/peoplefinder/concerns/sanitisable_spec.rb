require 'rails_helper'

RSpec.describe Peoplefinder::Concerns::Sanitisable do

  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    def persisted?
      false
    end

    attr_accessor :colour, :shape

    include Peoplefinder::Concerns::Sanitisable
    sanitise_fields :colour
  end

  subject { TestModel.new(colour: ' orange ', shape: ' square  ') }

  describe 'when model is validated' do
    before do
      subject.valid?
    end

    it 'strips white spaces from selected fields' do
      expect(subject.colour).to eql('orange')
    end

    it 'leaves other fields unchanged' do
      expect(subject.shape).to eql(' square  ')
    end
  end
end
