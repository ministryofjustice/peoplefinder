class ImportService

	def initialize(questionsService = QuestionsService.new)
    	@questionsService = questionsService
  	end

	def today_questions
		questions_processed = Array.new
		errors = Array.new

    pro = Progress.find_by_name('Unallocated')


		questions = @questionsService.questions
    questions.each do |q|
	      	pq = PQ.find_or_initialize_by(uin: q['Uin'])
          default_deadline = DateTime.now.midnight.change ({:hour => 10 , :min => 30, :offset => 0 })
          deadline = pq.internal_deadline || default_deadline
          progress_id = pq.progress_id || pro.id
          pq.update(
            uin: q['Uin'],
            raising_member_id: q['TablingMember']['MemberId'],
            question: q['Text'],
            tabled_date: q['TabledDate'],
            member_name: q['TablingMember']['MemberName'],
            member_constituency: q['TablingMember']['Constituency'],
            house_name: q['House']['HouseName'],
            date_for_answer: q['DateForAnswer'],
            internal_deadline: deadline,
            registered_interest: q['RegisteredInterest'],
            question_type: q['QuestionType'],
            progress_id: progress_id
          )
			if pq.errors.empty?			
				questions_processed.push(q)			
			else				
				errors.push({ message: pq.errors.full_messages, question:q })
			end
    end
    {questions: questions_processed, errors: errors}
	end
end	