class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:edit, :update]

  def update
    if @invitation.change_state(invitation_params[:status],
      invitation_params[:reason_declined])
      notice(invitation_params[:status].to_sym)
    else
      error(:update_error)
    end
    redirect_to replies_path
  end

private

  def invitation_params
    params.require(:invitation).permit(:status, :reason_declined)
  end

  def set_invitation
    @invitation = scope.find(params[:id])
  end

  def scope
    current_user.invitations.invited
  end
end
