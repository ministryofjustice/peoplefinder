class ResponsibilitiesAgreementsController < ApplicationController
  before_action :retrieve_object, only: [:edit, :update]

  def edit
    if @responsibilities_agreement.budgetary_responsibilities.empty?
      @responsibilities_agreement.budgetary_responsibilities.build
    end
  end

  def update
    @responsibilities_agreement.attributes = responsibilities_agreement_params
    if @responsibilities_agreement.save
      notice :updated
      redirect_to home_path
    else
      error :failed_update
      render :edit
    end
  end

private

  def responsibilities_agreement_params
    params[:responsibilities_agreement].permit(
      :number_of_staff,
      :staff_engagement_score,
      budgetary_responsibilities_attributes: [
        :id, :budget_type, :value, :description
      ]
    )
  end

  def retrieve_object
    scope = Agreement.editable_by(current_user)
    agreement = scope.find(params[:id])
    @responsibilities_agreement = ResponsibilitiesAgreement.new(agreement)
  end
end
