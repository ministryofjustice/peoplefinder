class OrgController < ApplicationController
  def show
    render json: GroupHierarchy.new(Group.departments.first).to_hash
  end
end
