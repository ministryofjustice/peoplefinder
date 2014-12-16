require 'rails_helper'

RSpec.describe UserCSVRenderer do
  subject { parse(described_class.new(user, aggregator).to_csv) }
  let(:user) { create(:user, name: 'John Doe') }
  let(:aggregator) {
    [
      [:question, 'Alice', 'Bob'],
      [:rating_1, 1, 2],
      [:rating_2, nil, 3],
      [:leadership_comments, 'murrrrr', 'brainsssss']
    ]
  }

  def parse(csv)
    CSV.parse(csv)
  end

  it 'starts with the name and a blank line' do
    expect(subject[0]).to eql(['Name', 'John Doe'])
    expect(subject[1]).to eql([])
  end

  it 'translates the question field in the header' do
    expect(subject[2].first).to eql('Question')
  end

  it 'includes reviewer names in the header' do
    expect(subject[2].drop(1)).to eql(['Alice', 'Bob'])
  end

  it 'translates the questions' do
    expect(subject[3].first).to eql('1) Sets Future Direction')
  end

  it 'lists ratings' do
    expect(subject[3].drop(1)).to eql(['1', '2'])
    expect(subject[4].drop(1)).to eql([nil, '3'])
    expect(subject[5].drop(1)).to eql(['murrrrr', 'brainsssss'])
  end
end
