class AgreementsController < ApplicationController
  def new
    @agreement = Agreement.new
    set_implicit_parameter
  end

  def create
    @agreement = Agreement.new(agreement_params)
    set_implicit_parameter

    if @agreement.save
      redirect_to agreement_path(@agreement), notice: 'Agreement was successfully created.'
    else
      render :new
    end
  end

private
  def set_implicit_parameter
    @agreement.jobholder = current_user
  end

  def agreement_params
    params[:agreement].permit(:manager_email)
  end
end
