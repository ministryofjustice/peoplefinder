class ProfilePhotosController < ApplicationController

  def create
    photo = ProfilePhoto.create(profile_photo_params)
    # see carrier wave errors such as image_integrity_error
    if photo.valid?
      render text: photo.to_json
    else
      render json: { error: photo.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def profile_photo_params
    params.require(:profile_photo).permit(:image)
  end

end
