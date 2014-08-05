class HomeController < ApplicationController

  def show
     @group = Group.departments.first
     unless @group
       redirect_to new_group_path, notice: 'To use the People Finder, first create a top-level group (without a parent)'
     end
  end
end