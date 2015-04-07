class HomeController < ApplicationController
  def show
    @group = Group.department
    unless @group
      notice :top_level_group_needed
      redirect_to new_group_path
    end

    @org_structure = Group.arrange.to_h
  end
end
