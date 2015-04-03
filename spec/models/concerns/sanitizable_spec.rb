require 'rails_helper'

RSpec.describe Concerns::Sanitizable do

  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    def persisted?
      false
    end

    attr_accessor :color, :shape, :flavor, :smell

    include Concerns::Sanitizable
    sanitize_fields :color, strip: true
    sanitize_fields :shape, downcase: true
    sanitize_fields :flavor, downcase: true, strip: true
  end

  subject {
    TestModel.new(
      color: ' Orange ',
      shape: ' Square ',
      flavor: ' Strawberry ',
      smell: ' Rancid '
    )
  }

  describe 'when model is validated' do
    before do
      subject.valid?
    end

    it 'strips white spaces when requested' do
      expect(subject.color).to match(/\AOrange\z/i)
      expect(subject.flavor).to match(/\AStrawberry\z/i)
    end

    it 'downcases when requested' do
      expect(subject.shape).to match(/square/)
      expect(subject.flavor).to match(/strawberry/)
    end

    it 'leaves other fields unchanged' do
      expect(subject.smell).to eql(' Rancid ')
    end
  end
end
