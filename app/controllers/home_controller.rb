class HomeController < ApplicationController

  include UserAgentHelper

  def show
    @group = Group.department
    unless @group
      notice :top_level_group_needed
      redirect_to(new_group_path) && return
    end
    @all_people_count = @group.all_people_count
    @org_structure = Group.hierarchy_hash
  end
end
