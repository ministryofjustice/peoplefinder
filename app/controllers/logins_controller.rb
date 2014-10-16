class LoginsController < ApplicationController
  skip_before_action :ensure_user
  skip_before_action :check_review_period_is_open

  def new
    @login = Login.new
  end

  def create
    @login = Login.new(login_params)

    if @login.save
      session[:user_id] = @login.user.id

      notice :logged_in
      redirect_to_goal
    else
      render :new
    end
  end

  def destroy
    reset_session
    notice :logged_out
    redirect_to root_url
  end

private

  def login_params
    params.require(:login).permit(:username, :password)
  end
end
