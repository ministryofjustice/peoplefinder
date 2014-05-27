class PqsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pq, only: [:show, :update]

  # GET /pqs/1
  # GET /pqs/1.json
  def show
    @pq = PQ.find_by(uin: params[:id])
    if !@pq.present?
      redirect_to action: 'index'
    end
    @pq
  end

  # PATCH/PUT /pqs/1
  # PATCH/PUT /pqs/1.json
  def update
    respond_to do |format|
      if @pq.update(pq_params)
        format.html { redirect_to @pq, notice: 'Pq was successfully updated.' }
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
      params.require(:pq).permit(:internal_deadline)
    end
end
