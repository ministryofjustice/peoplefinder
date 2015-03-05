require 'rails_helper'

RSpec.describe Peoplefinder::GroupUpdateService, type: :service do
  let(:group) { build(:group) }
  let(:person_responsible) { build(:person) }
  subject { described_class.new(group: group, person_responsible: person_responsible) }

  it 'updates the group with the supplied parameters and returns the result' do
    params = double(Hash)
    result = Object.new
    expect(group).to receive(:update).and_return(result)
    expect(subject.update(params)).to eq(result)
  end
end
