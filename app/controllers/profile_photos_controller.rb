class ProfilePhotosController < ApplicationController
  def create
    photo = ProfilePhoto.create(profile_photo_params)
    render json: photo
  end

private

  def profile_photo_params
    params.require(:profile_photo).permit(:image)
  end
end
