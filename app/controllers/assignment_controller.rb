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
      @question = PQ.find_by(uin: params[:uin])
      @ao = ActionOfficer.find_by(email: params[:entity])
      @assignment = ActionOfficersPq.where(pq_id: @question.id, action_officer_id: @ao.id).first
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