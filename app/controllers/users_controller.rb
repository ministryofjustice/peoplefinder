class UsersController < ApplicationController
  def index
    @users = scope.all
  end

  def scope
    current_user.managees
  end
end
