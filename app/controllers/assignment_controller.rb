class AssignmentController < ApplicationController
  before_action AOTokenFilter
  before_action :set_data
 
  def index
  end

  def action

    @response = AllocationResponse.new(response_params)

    if !@response.valid?
      return render 'index'
    end

    response_action = @response.response_action

    if response_action == 'accept'
      accept
    end

    if response_action == 'reject'
      reject
    end

    render 'index'
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

    def response_params
      params.require(:allocation_response).permit(:response_action, :reason_option, :reason)
    end

end