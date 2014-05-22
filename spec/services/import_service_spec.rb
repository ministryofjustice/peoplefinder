require 'spec_helper'

describe 'ImportService' do
  	before(:each) do
	    @http_client = double('QuestionsHttpClient')
	    allow(@http_client).to receive(:questions) { import_questions_for_today }

	    questions_service = QuestionsService.new(@http_client)
	    @import_service = ImportService.new(questions_service)

	end
	it 'should XXXXXX' do		
		@today_questions = @import_service.today_questions()
		@today_questions.size.should eq(2)

		question_one = PQ.find_by(uin: 'HL784845')
		question_one.should_not be_nil
		question_one.raising_member_id.should eql(2479)
		question_one.question.should eql('Hello we are asking questions')

		question_two = PQ.find_by(uin: 'HL673892')
		question_two.should_not be_nil
		question_two.raising_member_id.should eql(9742)
		question_two.question.should eql("I'm asking questions too")

	end
end
