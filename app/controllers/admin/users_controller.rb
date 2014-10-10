module Admin
  class UsersController < AdminController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.all
    end

    def show
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      @user = User.new(user_params)

      if @user.save
        notice :created, name: @user
        redirect_to admin_users_path
      else
        render :new
      end
    end

    def update
      if @user.update(user_params)
        notice :updated, name: @user
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    def destroy
      if @user != current_user
        @user.delete
        notice :destroyed, name: @user
      end
      redirect_to admin_users_path
    end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).
        permit(:name, :email, :manager_id, :participant, :administrator)
    end
  end
end
