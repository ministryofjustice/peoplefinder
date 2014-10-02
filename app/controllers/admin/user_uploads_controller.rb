module Admin
  class UserUploadsController < Base
    def create
      upload = UserUpload.new(user_upload_params)
      if upload.save
        notice :uploaded
      else
        error :upload_failed
      end
      redirect_to admin_path
    end

  private

    def user_upload_params
      return {} unless params[:user_upload]
      params.require(:user_upload).permit(:file)
    end
  end
end
