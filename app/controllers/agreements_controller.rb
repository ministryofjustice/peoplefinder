class AgreementsController < ApplicationController
  before_action :set_agreement, only: [:show, :edit, :update, :destroy]

  # GET /agreements
  def index
    @agreements = Agreement.all
  end

  # GET /agreements/1
  def show
  end

  # GET /agreements/new
  def new
    @agreement = Agreement.new
    set_implicit_parameter
  end

  # GET /agreements/1/edit
  def edit
  end

  # POST /agreements
  def create
    @agreement = Agreement.new(agreement_params)
    set_implicit_parameter

    if @agreement.save
      redirect_to root_path, notice: 'Agreement was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /agreements/1
  def update
    if @agreement.update(agreement_params)
      redirect_to @agreement, notice: 'Agreement was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /agreements/1
  def destroy
    @agreement.destroy
    redirect_to agreements_url, notice: 'Agreement was successfully destroyed.'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_agreement
    @agreement = Agreement.find(params[:id])
    set_implicit_parameter
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def agreement_params
    case params[:scope]
    when :jobholder
      params[:agreement].permit(:manager_email)
    when :manager
      params[:agreement].permit(:jobholder_email)
    end
  end

  def set_implicit_parameter
    case params[:scope]
    when :jobholder
      @agreement.jobholder = current_user
    when :manager
      @agreement.manager = current_user
    end
  end
end
