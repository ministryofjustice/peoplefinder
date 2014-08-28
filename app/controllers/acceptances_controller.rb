class AcceptancesController < ApplicationController
  before_action :set_acceptance, only: [:edit, :update]

  def edit
  end

  def update
    @acceptance.update_attributes(acceptance_params)
    redirect_to submissions_path
  end

private

  def acceptance_params
    params.require(:acceptance).
      permit(:status)
  end

  def set_acceptance
    @acceptance = current_user.acceptances.where(id: params[:id]).first
  end
end
