module Peoplefinder
  class MembershipsController < ApplicationController
    def destroy
      membership = Membership.find(params[:id])
      membership.destroy
      notice :member_removed, person: membership.person, group: membership.group
      redirect_to params[:referer] || '/'
    end
  end
end
