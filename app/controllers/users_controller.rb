class UsersController < ApplicationController
  before_action :ensure_participant

  def index
    show_tabs
    @users = scope.all
  end

private

  def scope
    current_user.direct_reports
  end
end
