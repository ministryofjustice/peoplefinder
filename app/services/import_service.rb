class ImportService

	def initialize(questionsService = QuestionsService.new)
    	@questionsService = questionsService
  	end

	def today_questions
		questions = @questionsService.questions
    questions.each do |q|
			#puts newQ.valid?
			#save q to database
      pq = PQ.find_or_initialize_by(uin: q['Uin'])
			pq.update(uin: q['Uin'], raising_member_id: q['TablingMember']['MemberId'], question: q['Text'])
    end
    questions
	end
end	