require 'peoplefinder'

class Peoplefinder::HomeController < ApplicationController
  def show
    @group = Group.department
    unless @group
      notice :top_level_group_needed
      redirect_to new_group_path
    end
  end
end
