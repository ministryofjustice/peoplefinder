class CommissioningService

 	def initialize(tokenService = TokenService.new)
     	@tokenService = tokenService
 	end

	def send(assignment)
    raise 'Action Officer is not selected' if assignment.action_officer_id.nil?
    raise 'Question is not selected' if assignment.pq_id.nil?

		ActionOfficersPq.create(action_officer_id: assignment.action_officer_id, pq_id: assignment.pq_id, accept: false, reject: false, transfer: false)
		ao = ActionOfficer.find(assignment.action_officer_id)
		pq = PQ.find_by(id: assignment.pq_id)
		path = '/assignment/' + pq.uin.encode

		tomorrow_midnight = DateTime.now.midnight.change({:offset => 0}) + 1.days
		token = @tokenService.generate_token(path, ao.email, tomorrow_midnight)
		
		template = Hash.new
		template[:name] = ao.name
		template[:email] = ao.email
		template[:uin] = pq.uin
		template[:question] = pq.question		
		template[:token] = token

		PqMailer.commit_email(template).deliver
		
		return token
	end
end