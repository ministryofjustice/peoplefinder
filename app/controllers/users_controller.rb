class UsersController < ApplicationController
  before_action :ensure_participant

  def index
    @users = scope.all
  end

  def scope
    current_user.managees
  end
end
