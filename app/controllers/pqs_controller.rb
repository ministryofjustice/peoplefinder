class PqsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pq, only: [:show, :update]

  def index
    redirect_to controller: 'dashboard'
  end

  # GET /pqs/1
  # GET /pqs/1.json
  def show
    @pq = PQ.find_by(uin: params[:id])
    if !@pq.present?
      redirect_to action: 'index'
    end
    @pq
  end

  def commission
    @pq = PQ.find_by(uin: params[:id])
    if !@pq.present?
      redirect_to action: 'index'
    end
    # TODO move into put action
    # @user = User.find(1)
    # PqMailer.commit_email(@user,@pq).deliver
    @pq 
  end

  # PATCH/PUT /pqs/1
  # PATCH/PUT /pqs/1.json
  def update
    respond_to do |format|
      if @pq.update(pq_params)
        flash[:success] = 'Successfully updated'
        format.html { redirect_to action: 'show', id: @pq.uin }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @pq.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pqs/1
  # DELETE /pqs/1.json
  #def destroy
  #  @pq.destroy
  #  respond_to do |format|
  #    format.html { redirect_to pqs_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
    def set_pq
      @pq = PQ.find_by(uin: params[:id])
    end

    def pq_params
      params.require(:pq).permit(:internal_deadline, :seen_by_finance, :press_interest, :finance_interest)
    end
end
