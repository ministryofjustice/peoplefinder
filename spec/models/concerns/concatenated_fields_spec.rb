require 'rails_helper'

RSpec.describe Concerns::ConcatenatedFields do

  class TestModel
    attr_accessor :field_a, :field_b

    include Concerns::ConcatenatedFields
    concatenated_field :concatenated, :field_a, :field_b, join_with: ', '
    concatenated_field :concat_missing, :field_a, :field_c, join_with: ', '
  end

  subject { TestModel.new }

  it 'omits blank fields' do
    subject.field_a = ''
    subject.field_b = 'bravo'
    expect(subject.concatenated).to eq('bravo')
  end

  it 'joins using the specified join_with value' do
    subject.field_a = 'alpha'
    subject.field_b = 'bravo'
    expect(subject.concatenated).to eq('alpha, bravo')
  end

  it 'ignores missing attributes' do
    subject.field_a = 'alpha'
    expect(subject.concat_missing).to eq('alpha')
  end

  context 'Person model' do
    it 'does not prevent output for queries using .select' do
      expect { puts Person.unscoped.select("count(people.id)") }.to output(/\n/).to_stdout
    end
  end

end
