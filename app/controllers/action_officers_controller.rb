class ActionOfficersController < ApplicationController
  before_action :set_action_officer, only: [:show, :edit, :update, :destroy]

  # GET /action_officers
  # GET /action_officers.json
  def index
    @action_officers = ActionOfficer.all
  end

  # GET /action_officers/1
  # GET /action_officers/1.json
  def show
  end

  # GET /action_officers/new
  def new
    @action_officer = ActionOfficer.new
  end

  # GET /action_officers/1/edit
  def edit
  end

  # POST /action_officers
  # POST /action_officers.json
  def create
    @action_officer = ActionOfficer.new(action_officer_params)

    respond_to do |format|
      if @action_officer.save
        format.html { redirect_to @action_officer, notice: 'Action officer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @action_officer }
      else
        format.html { render action: 'new' }
        format.json { render json: @action_officer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /action_officers/1
  # PATCH/PUT /action_officers/1.json
  def update
    respond_to do |format|
      if @action_officer.update(action_officer_params)
        format.html { redirect_to @action_officer, notice: 'Action officer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @action_officer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /action_officers/1
  # DELETE /action_officers/1.json
  def destroy
    @action_officer.destroy
    respond_to do |format|
      format.html { redirect_to action_officers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_action_officer
      @action_officer = ActionOfficer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def action_officer_params
      params.require(:action_officer).permit(:name, :email)
    end
end
