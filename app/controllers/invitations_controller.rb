class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:edit, :update]

  def update
    if @invitation.update(invitation_params)
      notice @invitation.status
    else
      error :update_error
    end
    redirect_to replies_path
  end

private

  def invitation_params
    params.require(:invitation).permit(:status, :reason_declined)
  end

  def set_invitation
    @invitation = Invitation.new(scope.find(params[:id]))
  end

  def scope
    current_user.replies.invited
  end
end
