class CommissionController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pq, only: [:show, :update]

  def commission
    @pq = PQ.find_by(uin: params[:id])
    if @pq.nil?
      flash[:notice] = 'Question not found'
      redirect_to action: 'index'
    else
      @aap = ActionOfficersPq.new
      @aap.pq_id = @pq.id
      @aap
    end
  end

  def assign
    pq_id = params[:action_officers_pq][:pq_id]
    # "action_officers_pq"=>{"action_officer_id"=>["", "1", "2"]
    params[:action_officers_pq][:action_officer_id].each do |ao_id| 
      if !ao_id.empty? 
        assignment = ActionOfficersPq.new(pq_id: pq_id, action_officer_id: ao_id)
        comm_service = CommissioningService.new
        result = comm_service.send(assignment)
      end
      # begin
  #       if result.nil?
  #         flash[:error] = "Error in commissioning to #{assignment.action_officer.name}"
  #         return redirect_to action: 'commission', id: @pq.uin
  #       end
  #     rescue => e
  #       flash[:error] = "#{e}"
  #       return redirect_to action: 'commission', id: @pq.uin
  #     end      
    end
    
    @pq = PQ.find(pq_id)
    flash[:success] = "Successfully allocated #{@pq.uin}"
    return redirect_to controller: 'pqs', action: 'show', id: @pq.uin 
    
  end    

  private
    def set_pq
      @pq = PQ.find_by(uin: params[:id])
    end

    def assignment_params
      # TODO: Check the permit again
      # params.require(:action_officers_pq).permit(:action_officer_id, :pq_id)
    end
end
