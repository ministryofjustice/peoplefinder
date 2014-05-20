class UsersController < ApplicationController
  respond_to :html
  before_action :authenticate_user!


  def index
    @users = User.page(params[:page]).per_page(15).order('email')
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    flash[:notice] = 'User updated' if @user.update_attributes(user_params)
    @user
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    @user
  end

  protected
  def user_params
    params.require(:users).permit(:email, :admin, :name)
  end

end
