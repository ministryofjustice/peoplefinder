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
    redirect_to '/', notice: 'Agreement was successfully created.'
  end

  def edit
    @agreement = Agreement.editable_by(current_user).find(params[:id])
    initialise_objectives_and_budgetary_responsibilities
  end

  def index
    @agreements = scope
  end

  def update
    @agreement = Agreement.editable_by(current_user).find(params[:id])
    @agreement.update_attributes(agreement_params)
    redirect_to '/'
  end

private
  def set_implicit_parameter
    @agreement.jobholder = current_user
  end

  def agreement_params
    params[:agreement].permit(:manager_email, :number_of_staff, :staff_engagement_score,
      budgetary_responsibilities: [:budget_type, :budget_value, :description],
      objectives: [:objective_type, :description, :deliverable, :measures])
  end

  def scope
    Agreement.editable_by(current_user)
  end

  def initialise_objectives_and_budgetary_responsibilities
    @agreement.budgetary_responsibilities = [{}] unless @agreement.budgetary_responsibilities
    @agreement.objectives = [{}] unless @agreement.objectives
  end
end
