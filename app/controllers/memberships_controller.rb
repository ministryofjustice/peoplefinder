class MembershipsController < ApplicationController

  def destroy
    membership = Membership.find(params[:id])
    notice = "Removed #{ membership.person} from #{ membership.group }"
    membership.destroy
    redirect_to params[:referer] || '/', notice: notice
  end
end
