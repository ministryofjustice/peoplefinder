class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:edit, :update]

  def update
    @invitation.update_attributes(invitation_params)
    redirect_to replies_path
  end

private

  def invitation_params
    params.require(:invitation).permit(:status, :rejection_reason)
  end

  def set_invitation
    @invitation = scope.find(params[:id])
  end

  def scope
    current_user.invitations
  end
end
