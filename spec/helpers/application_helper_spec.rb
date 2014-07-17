require 'rails_helper'
include ApplicationHelper

describe 'ApplicationHelper' do

  describe '#financial_year' do
    it 'should display a date in March 2014 to 2013/14' do
      the_date = Date.new(2014, 3, 31)
      expect(financial_year(the_date)).to eql('2013/14')
    end

    it 'should display a date in April 2014 to 2014/15' do
      the_date = Date.new(2014, 4, 1)
      expect(financial_year(the_date)).to eql('2014/15')
    end
  end
end
