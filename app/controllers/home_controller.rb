class HomeController < ApplicationController

  include UserAgentHelper

  before_action :unsupported_browser_redirect, only: [:show]

  def show
    @group = Group.department
    unless @group
      notice :top_level_group_needed
      redirect_to(new_group_path) && return
    end
    @all_people_count = @group.all_people_count
    @org_structure = Group.hierarchy_hash
  end

  def unsupported_browser_continue
    session[:continue_using_unsupported_browser] = true
    redirect_to action: :show
  end

  private

  def continue_using_unsupported_browser?
    session.fetch(:continue_using_unsupported_browser, false)
  end

  def unsupported_browser_redirect
    redirect_to unsupported_browser_path if unsupported_browser? && !continue_using_unsupported_browser?
  end

end
