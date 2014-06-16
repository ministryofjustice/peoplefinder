class AssignmentController < ApplicationController
  before_action AOTokenFilter
  before_action :set_data
 
  def index
    @response = AllocationResponse.new()
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
      @assignment.update_attributes(accept: true, reject: false)

      # send the email with the info
      template = Hash.new
      template[:name] = @ao.name
      template[:email] = @ao.email
      template[:uin] = @question.uin
      template[:question] = @question.question
      template[:mpname] = @question.minister.name unless @question.minister.nil?
      template[:mpemail] = @question.minister.email unless @question.minister.nil?
      template[:policy_mpname] = @question.policy_minister.name unless @question.policy_minister.nil?
      template[:policy_mpemail] = @question.policy_minister.email unless @question.policy_minister.nil?
      PQAcceptedMailer.commit_email(template).deliver

    end

    def reject
      flash[:notice] = 'The Question is rejected'
      @assignment.update_attributes(accept: false, reject: true, reason_option: @response.reason_option, reason: @response.reason)
    end

    def response_params
      params.require(:allocation_response).permit(:response_action, :reason_option, :reason)
    end

end