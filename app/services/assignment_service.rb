class AssignmentService

  def accept(assignment)
    assignment.update_attributes(accept: true, reject: false)

    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = PQ.find_by(id: assignment.pq_id)

    pro = Progress.find_by_name('Allocated Accepted')
    pq.update progress_id: pro.id

    template = Hash.new
    template[:name] = ao.name
    template[:email] = ao.email
    template[:uin] = pq.uin
    template[:question] = pq.question
    template[:mpname] = pq.minister.name unless pq.minister.nil?
    template[:mpemail] = pq.minister.email unless pq.minister.nil?
    template[:policy_mpname] = pq.policy_minister.name unless pq.policy_minister.nil?
    template[:policy_mpemail] = pq.policy_minister.email unless pq.policy_minister.nil?
    PQAcceptedMailer.commit_email(template).deliver

  end


  def reject(assignment, response)
    assignment.update_attributes(accept: false, reject: true, reason_option: response.reason_option, reason: response.reason)
  end
end