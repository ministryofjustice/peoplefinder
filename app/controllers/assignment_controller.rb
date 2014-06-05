class AssignmentController < ApplicationController
  before_action AOTokenFilter
  before_action :set_data
 
  def index

    action = params[:response]

    if action == 'accept'
      accept
    end

    if action == 'reject'
      reject
    end

    if action == 'transfer'
      transfer
    end

  end

  private
    def set_data
      # the entity is in this format "assignment:<id>"
      # for example "assignment:3"
      entity = params[:entity].split(':')
      assignment_id = entity[1]

      if assignment_id.nil?
        return render :file => 'public/401.html', :status => :unauthorized
      end

      @assignment = ActionOfficersPq.find(assignment_id)

      if @assignment.nil?
        return render :file => 'public/401.html', :status => :unauthorized
      end

      @question = PQ.find_by(uin: params[:uin])
      @ao = @assignment.action_officer

    end

    def accept
      flash[:notice] = 'The Question is accepted'
      @assignment.update_attributes(accept: true, reject: false, transfer: false)
    end

    def reject
      flash[:notice] = 'The Question is rejected'
      @assignment.update_attributes(accept: false, reject: true, transfer: false)
    end

    def transfer
      flash[:notice] = 'The Question is mark for transfer'
      @assignment.update_attributes(accept: false, reject: false, transfer: true)
    end

end