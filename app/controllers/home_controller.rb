class HomeController < ApplicationController

  include UserAgentHelper

  before_action :set_department_or_redirect, only: [:show]

  def show
    @all_people_count = @department.all_people_count
    @org_structure = Group.hierarchy_hash
  end

  def can_add_person_here?
    params['action'] == 'show'
  end

  private

  def set_department_or_redirect
    @department = Group.department
    if @department
      redirect_to ENV['HOME_PAGE_URL'] if ENV['HOME_PAGE_URL']
    else
      notice :top_level_group_needed
      redirect_to(new_group_path) && return
    end
  end
end
