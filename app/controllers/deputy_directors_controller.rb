class DeputyDirectorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deputy_director, only: [:show, :edit, :update, :destroy]
  before_action :prepare_divisions

  # GET /deputy_directors
  # GET /deputy_directors.json
  def index
    @deputy_directors = DeputyDirector.all
  end

  # GET /deputy_directors/1
  # GET /deputy_directors/1.json
  def show
  end

  # GET /deputy_directors/new
  def new
    @deputy_director = DeputyDirector.new
  end

  # GET /deputy_directors/1/edit
  def edit
  end

  # POST /deputy_directors
  # POST /deputy_directors.json
  def create
    @deputy_director = DeputyDirector.new(deputy_director_params)

    respond_to do |format|
      if @deputy_director.save
        format.html { redirect_to @deputy_director, notice: 'Deputy director was successfully created.' }
        format.json { render action: 'show', status: :created, location: @deputy_director }
      else
        format.html { render action: 'new' }
        format.json { render json: @deputy_director.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deputy_directors/1
  # PATCH/PUT /deputy_directors/1.json
  def update
    respond_to do |format|
      if @deputy_director.update(deputy_director_params)
        format.html { redirect_to @deputy_director, notice: 'Deputy director was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @deputy_director.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deputy_directors/1
  # DELETE /deputy_directors/1.json
  def destroy
    @deputy_director.destroy
    respond_to do |format|
      format.html { redirect_to deputy_directors_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deputy_director
      @deputy_director = DeputyDirector.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def deputy_director_params
      params.require(:deputy_director).permit(:name, :email, :deleted, :division_id)
    end
    def prepare_divisions
      @divisions = Division.where(deleted: false).all
    end
end
