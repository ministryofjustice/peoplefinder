class PressDesksController < ApplicationController
  before_action :set_press_desk, only: [:show, :edit, :update, :destroy]

  # GET /press_desks
  # GET /press_desks.json
  def index
    @press_desks = PressDesk.all
  end

  # GET /press_desks/1
  # GET /press_desks/1.json
  def show
  end

  # GET /press_desks/new
  def new
    @press_desk = PressDesk.new
  end

  # GET /press_desks/1/edit
  def edit
  end

  # POST /press_desks
  # POST /press_desks.json
  def create
    @press_desk = PressDesk.new(press_desk_params)

    respond_to do |format|
      if @press_desk.save
        format.html { redirect_to @press_desk, notice: 'Press desk was successfully created.' }
        format.json { render action: 'show', status: :created, location: @press_desk }
      else
        format.html { render action: 'new' }
        format.json { render json: @press_desk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /press_desks/1
  # PATCH/PUT /press_desks/1.json
  def update
    respond_to do |format|
      if @press_desk.update(press_desk_params)
        format.html { redirect_to @press_desk, notice: 'Press desk was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @press_desk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /press_desks/1
  # DELETE /press_desks/1.json
  def destroy
    @press_desk.destroy
    respond_to do |format|
      format.html { redirect_to press_desks_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_press_desk
      @press_desk = PressDesk.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def press_desk_params
      params.require(:press_desk).permit(:name, :deleted)
    end
end
