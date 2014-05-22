class ImportService

	def initialize(questionsService = QuestionsService.new)
    	@questionsService = questionsService
  	end

	def today_questions
		qarray = @questionsService.questions
		qarray.each do |q|
			#puts newQ.valid?
			#save q to database
			newQ = PQ.create(uin: q['Uin'], raising_member_id: q['TablingMember']['MemberId'],question: q['Text'])
			puts newQ.valid?
			newQ.save()
		end
	end
end	