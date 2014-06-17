class MinistersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_minister, only: [:show, :edit, :update, :destroy]

  # GET /ministers
  # GET /ministers.json
  def index
    @ministers = Minister.all
  end

  # GET /ministers/1
  # GET /ministers/1.json
  def show
  end

  # GET /ministers/new
  def new
    @minister = Minister.new
  end

  # GET /ministers/1/edit
  def edit
  end

  # POST /ministers
  # POST /ministers.json
  def create
    @minister = Minister.new(minister_params)

    respond_to do |format|
      if @minister.save
        format.html { redirect_to @minister, notice: 'Minister was successfully created.' }
        format.json { render action: 'show', status: :created, location: @minister }
      else
        format.html { render action: 'new' }
        format.json { render json: @minister.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ministers/1
  # PATCH/PUT /ministers/1.json
  def update
    respond_to do |format|
      if @minister.update(minister_params)
        format.html { redirect_to @minister, notice: 'Minister was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @minister.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ministers/1
  # DELETE /ministers/1.json
  def destroy
    @minister.destroy
    respond_to do |format|
      format.html { redirect_to ministers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_minister
      @minister = Minister.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def minister_params
      params.require(:minister).permit(:name, :title, :email, :deleted)
    end
end
