require 'spec_helper'

describe 'QuestionsService' do

  before(:each) do
    http_client = QuestionsMockHttpClient.new(sample_questions)
    @questions_service = QuestionsService.new(http_client)
  end

  it 'should return a list of questions with data' do
    questions = @questions_service.questions_by_date()
    uin = questions[0]["Uin"]
    uin.should eq('HL4837')

    uin = questions[1]["Uin"]
    uin.should eq('HL4838')

    update_date = questions[1]["UpdatedDate"]
    update_date.should eq('2013-02-04T10:30:46.45327Z')

  end

  it 'should have data for TablingMember (asking MP)' do
    questions = @questions_service.questions_by_date()
    questions[0]['TablingMember']['MemberId'].should eq('2479')
    questions[0]['TablingMember']['MemberName'].should eq('Diana Johnson')
  end

  it 'should identify which house it is from' do
    questions = @questions_service.questions_by_date()
    questions[0]['House']['HouseId'].should eq('2')
    questions[0]['House']['HouseName'].should eq('House of Lords')
  end


  it 'should raise an error if the date is not valid' do
    expect {
      @questions_service.questions_by_date("baddate")
    }.to raise_error
  end



end

