class HomeController < ApplicationController

  include UserAgentHelper

  before_action :set_department_or_redirect, only: [:show, :index]

  def show; end

  def index
    @all_people_count = @department.all_people_count
    @org_structure = Group.hierarchy_hash
  end

  def can_add_person_here?
    true
  end

  private

  def set_department_or_redirect
    @department = Group.department
    unless @department
      notice :top_level_group_needed
      redirect_to(new_group_path) && return
    end
  end

end
