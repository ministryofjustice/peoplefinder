class AgreementsController < ApplicationController
  def new
    @agreement = Agreement.new
    initialise_objectives_and_budgetary_responsibilities
    set_implicit_parameter
  end

  def create
    @agreement = Agreement.new(agreement_params)
    set_implicit_parameter

    @agreement.save
    notice :created
    redirect_to home_path
  end

  def edit
    @agreement = scope.find(params[:id])
    initialise_objectives_and_budgetary_responsibilities
  end

  def index
    @agreements = scope
  end

  def update
    @agreement = scope.find(params[:id])
    @agreement.attributes = agreement_params
    if @agreement.save
      notice :updated
      redirect_to home_path
    else
      error :failed_update
      render :edit
    end
  end

private
  def set_implicit_parameter
    @agreement.jobholder = current_user
  end

  def agreement_params
    params[:agreement].permit(:manager_email, :number_of_staff, :staff_engagement_score,
      objectives_attributes: [:id, :objective_type, :description, :deliverables, :measurements],
      budgetary_responsibilities_attributes: [:id, :budget_type, :value, :description]
    )
  end

  def scope
    Agreement.editable_by(current_user)
  end

  def initialise_objectives_and_budgetary_responsibilities
    @agreement.budgetary_responsibilities.build if @agreement.budgetary_responsibilities.empty?
    @agreement.objectives.build if @agreement.objectives.empty?
  end
end
