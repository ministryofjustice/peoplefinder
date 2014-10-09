module Peoplefinder
  class OrgController < ApplicationController
    def show
      render json: GroupHierarchy.new(Group.department).to_hash
    end
  end
end
