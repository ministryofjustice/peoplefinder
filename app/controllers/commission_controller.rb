class CommissionController < ApplicationController
  before_action :authenticate_user!

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
    @pq = PQ.find(pq_id)
    
    comm = params[:action_officers_pq][:action_officer_id]
    if comm.size==1 && comm.first.empty?
      flash[:error] = "Please select at least one Action Officer"
      return redirect_to action: 'commission', id: @pq.uin
    end
    
    params[:action_officers_pq][:action_officer_id].each do |ao_id| 
      if !ao_id.empty? 
        assignment = ActionOfficersPq.new(pq_id: pq_id, action_officer_id: ao_id)
        comm_service = CommissioningService.new
        result = comm_service.send(assignment)
        begin
          if result.nil?
            flash[:error] = "Error in commissioning to #{assignment.action_officer.name}"
            return redirect_to action: 'commission', id: @pq.uin
          end
        rescue => e
          flash[:error] = "#{e}"
          return redirect_to action: 'commission', id: @pq.uin
        end              
      end
    end
    
    flash[:success] = "Successfully allocated #{@pq.uin}"
    return redirect_to controller: 'pqs', action: 'show', id: @pq.uin 
    
  end    

  private
    def assignment_params
      # TODO: Check the permit again
      # params.require(:action_officers_pq).permit(:action_officer_id, :pq_id)
    end
end
