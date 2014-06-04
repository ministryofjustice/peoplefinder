class AssignmentController < ApplicationController
  before_action AOTokenFilter
  before_action :set_data
 
  def index
  	
  end


  def accept
  	@assignment.update_attributes(accept: true)
  	render 'index'
  end

  def reject
  	@assignment.update_attributes(reject: true)
  	render 'index'
  end

  def transfer
  	@assignment.update_attributes(transfer: true)
  	render 'index'
  end


  private
    def set_data
      @question = PQ.find_by(uin: params[:uin])
      @ao = ActionOfficer.find_by(email: params[:email])
      @assignment = ActionOfficersPq.where(pq_id: @question.id, action_officer_id: @ao.id).first
    end

end