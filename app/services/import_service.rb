class ImportService

	def initialize(questionsService = QuestionsService.new)
    	@questionsService = questionsService
  	end

	def today_questions
		questions_processed = Array.new
		errors = Array.new

		questions = @questionsService.questions
    	questions.each do |q|
	      	pq = PQ.find_or_initialize_by(uin: q['Uin'])
			pq.update(uin: q['Uin'], raising_member_id: q['TablingMember']['MemberId'], question: q['Text'])
			
			if pq.errors.empty?			
				questions_processed.push(q)			
			else				
				errors.push({ message: pq.errors.full_messages, question:q })
			end

    	end
    	{questions: questions_processed, errors: errors}
	end
end	