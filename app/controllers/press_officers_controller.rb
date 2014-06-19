class PressOfficersController < ApplicationController
  before_action :set_press_officer, only: [:show, :edit, :update, :destroy]
  before_action :prepare_press_offices

  # GET /press_officers
  # GET /press_officers.json
  def index
    @press_officers = PressOfficer.all
  end

  # GET /press_officers/1
  # GET /press_officers/1.json
  def show
  end

  # GET /press_officers/new
  def new
    @press_officer = PressOfficer.new
  end

  # GET /press_officers/1/edit
  def edit
  end

  # POST /press_officers
  # POST /press_officers.json
  def create
    @press_officer = PressOfficer.new(press_officer_params)

    respond_to do |format|
      if @press_officer.save
        format.html { redirect_to @press_officer, notice: 'Press officer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @press_officer }
      else
        format.html { render action: 'new' }
        format.json { render json: @press_officer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /press_officers/1
  # PATCH/PUT /press_officers/1.json
  def update
    respond_to do |format|
      if @press_officer.update(press_officer_params)
        format.html { redirect_to @press_officer, notice: 'Press officer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @press_officer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /press_officers/1
  # DELETE /press_officers/1.json
  def destroy
    @press_officer.destroy
    respond_to do |format|
      format.html { redirect_to press_officers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_press_officer
      @press_officer = PressOfficer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def press_officer_params
      params.require(:press_officer).permit(:name, :email, :press_desk_id, :deleted)
    end
    def prepare_press_offices
      @press_offices = PressDesk.where(deleted: false).all
    end
end
