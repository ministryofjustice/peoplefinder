require 'spec_helper'

describe 'ImportService' do

  before(:each) do
    @http_client = double('QuestionsHttpClient')
    allow(@http_client).to receive(:questions) { import_questions_for_today }

    questions_service = QuestionsService.new(@http_client)
    @import_service = ImportService.new(questions_service)
  end

  describe '#today_questions' do
    it 'should store today questions into the data model' do
      import_result = @import_service.today_questions()
      import_result[:questions].size.should eq(2)

      question_one = PQ.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.raising_member_id.should eql(2479)
      question_one.question.should eql('Hello we are asking questions')

      question_two = PQ.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      question_two.raising_member_id.should eql(9742)
      question_two.question.should eql("I'm asking questions too")

    end

    it 'should update the question data if #today_questions is called multiple times' do

      # First call
      import_result = @import_service.today_questions()
      import_result[:questions].size.should eq(2)

      question_one = PQ.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.question.should eql('Hello we are asking questions')

      question_two = PQ.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      question_two.question.should eql("I'm asking questions too")

      # Second call, with different xml response
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_changes }

      @import_service.today_questions()

      question_one = PQ.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.question.should eql('Hello we are asking questions')

      question_two = PQ.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      # The question text is different now
      question_two.question.should eql("The Text Changed")

    end


    it 'should create new question, if you get new questions from the api' do

      # First call
      import_result = @import_service.today_questions()
      import_result[:questions].size.should eq(2)

      question_one = PQ.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.question.should eql('Hello we are asking questions')

      question_two = PQ.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      question_two.question.should eql("I'm asking questions too")

      question_new = PQ.find_by(uin: 'HL5151')
      question_new.should be_nil

      # Second call, with one new question
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_changes }

      @import_service.today_questions()

      question_new = PQ.find_by(uin: 'HL5151')
      question_new.should_not be_nil
      question_new.question.should eql('New question in the api')

    end

    it 'should return error hash when sent malformed XML from api' do
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_missing_uin }
      import_result = @import_service.today_questions()

      import_result[:questions].size.should eql(1)

      errors = import_result[:errors]
      errors.size.should eql(1)	  

      err = errors.first

	  err[:message].should eql(["Uin can't be blank"])
	  question_with_error = err[:question]

	  question_with_error['Text'].should eql("I'm asking questions too")
	  question_with_error['Uin'].should be_nil	  

    end
  end
end
