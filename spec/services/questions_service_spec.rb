require 'spec_helper'

describe 'QuestionsService' do

  before(:each) do
    @questions_service = QuestionsService.new(sample_questions)
    @questions = @questions_service.questions_by_date()
  end
  it 'should return a list of questions with data' do

    uin = @questions[0]["Uin"]
    uin.should eq('HL4837')

    uin = @questions[1]["Uin"]
    uin.should eq('HL4838')

    update_date = @questions[1]["UpdatedDate"]
    update_date.should eq('2013-02-04T10:30:46.45327Z')

  end
  it 'should have data for TablingMember (asking MP)' do
      @questions[0]['TablingMember']['MemberId'].should eq('2479')
      @questions[0]['TablingMember']['MemberName'].should eq('Diana Johnson')
    end
    it 'should identify which house it is from' do
      @questions[0]['House']['HouseId'].should eq('2')
      @questions[0]['House']['HouseName'].should eq('House of Lords')
    end
end

