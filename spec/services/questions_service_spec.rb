require 'spec_helper'

describe 'QuestionsService' do

  before(:each) do
    @http_client = double('QuestionsHttpClient')
    allow(@http_client).to receive(:questions) { sample_questions }

    @questions_service = QuestionsService.new(@http_client)
  end
  describe 'parsing xml questions' do
    it 'should return a list of questions with data' do
      questions = @questions_service.questions()
      uin = questions[0]["Uin"]
      uin.should eq('174151')

      uin = questions[1]["Uin"]
      uin.should eq('174152')

      update_date = questions[1]["UpdatedDate"]
      update_date.should eq('2014-01-17T11:28:02.263Z')

    end

    it 'should have data for TablingMember (asking MP)' do
      questions = @questions_service.questions()
      questions[0]['TablingMember']['MemberId'].should eq('308')
      questions[0]['TablingMember']['MemberName'].should eq('Mr Jim Cunningham')
    end

    it 'should identify which house it is from' do
      questions = @questions_service.questions()
      questions[0]['House']['HouseId'].should eq('1')
      questions[0]['House']['HouseName'].should eq('House of Commons')
    end
  end

  describe '#questions' do
    it 'should raise an error if the date is not valid' do
      expect {
        @questions_service.questions(dateFrom: "baddate")
      }.to raise_error()
    end

    it 'should pass dateFrom to httpclient in the right date format' do

      expect(@http_client).to receive(:questions).with({"dateFrom"=>"2014-02-01T00:00:00"})

      @questions_service.questions(dateFrom: Date.new(2014, 2, 1))
    end

    it 'should pass dateFrom and dateTo and to httpclient in the right date format' do
      day = Date.new(2014, 2, 1)
      day_plus_one = day + 1
      expect(@http_client).to receive(:questions).with({
                                                           "dateFrom"=>"2014-02-01T00:00:00",
                                                           "dateTo"=>"2014-02-02T00:00:00",
                                                       })

      @questions_service.questions(dateFrom: day, dateTo: day_plus_one)
    end

    it 'should pass dateFrom, dateTo, and status to httpclient' do
      day = Date.new(2014, 2, 1)
      day_plus_one = day + 1
      expect(@http_client).to receive(:questions).with({
                                                           "dateFrom"=>"2014-02-01T00:00:00",
                                                           "dateTo"=>"2014-02-02T00:00:00",
                                                           "status"=>"Tabled"
                                                       })

      @questions_service.questions(dateFrom: day, dateTo: day_plus_one, status: "Tabled")
    end

  end

  describe '#questions_by_uin' do
    it 'should retrieve the question by Uin' do
      allow(@http_client).to receive(:question) { sample_questions_by_uin }

      uin = "HL4837"
      expect(@http_client).to receive(:question).with(uin)
      question = @questions_service.questions_by_uin(uin)
      question["Uin"].should eq('HL4837')
    end
  end



end

