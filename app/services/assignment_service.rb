class AssignmentService

  def accept(assignment)
    assignment.update_attributes(accept: true, reject: false)
  end


  def reject(assignment, response)
    assignment.update_attributes(accept: false, reject: true, reason_option: response.reason_option, reason: response.reason)
  end
end