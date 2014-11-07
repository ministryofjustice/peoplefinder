require 'rails_helper'

describe DaysHelper do
  include described_class

  it 'rounds days down' do
    expect(number_of_days_in_words(40.25 * 24 * 60 * 60)).to eql('40 days')
  end

  it 'inflects the number of days' do
    expect(number_of_days_in_words(1 * 24 * 60 * 60)).to eql('one day')
    expect(number_of_days_in_words(2 * 24 * 60 * 60)).to eql('2 days')
  end

  it 'treats less than one day specially' do
    expect(number_of_days_in_words(0.5 * 24 * 60 * 60)).to eql('less than a day')
  end
end
