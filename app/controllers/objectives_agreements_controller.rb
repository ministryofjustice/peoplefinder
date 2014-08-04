class ObjectivesAgreementsController < ApplicationController
  before_action :retrieve_object, only: [:edit, :update]

  def edit
    if @objectives_agreement.objectives.empty?
      @objectives_agreement.objectives.build
    end
  end

  def update
    @objectives_agreement.attributes = objectives_agreement_params
    if @objectives_agreement.save
      notice :updated
      redirect_to home_path
    else
      error :failed_update
      render :edit
    end
  end

private

  def objectives_agreement_params
    params[:objectives_agreement].permit(
      *permitted_params_for_current_user,
      objectives_attributes: [
        :id, :objective_type, :description, :deliverables, :measurements
      ]
    )
  end

  def permitted_params_for_current_user
    if current_user == @objectives_agreement.manager
      [:objectives_signed_off_by_manager]
    elsif current_user == @objectives_agreement.staff_member
      [:objectives_signed_off_by_staff_member]
    else
      []
    end
  end

  def retrieve_object
    scope = Agreement.editable_by(current_user)
    agreement = scope.find(params[:id])
    @objectives_agreement = ObjectivesAgreement.new(agreement)
  end
end
