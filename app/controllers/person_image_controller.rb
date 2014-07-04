class PersonImageController < ApplicationController
  before_action :set_person

  def edit
    @image = @person.image
    unless @image.present?
      redirect_to edit_person_path(@person), notice: "No image has been uploaded for #{ @person }"
    end
  end

  def update
    @person.assign_attributes(person_params)

    if @person.image.recreate_versions!
      redirect_to person_path(@person, cache_bust: Time.now.to_param), notice: "Cropped #{ @person }'s image."
    else
      render action: 'edit'
    end
  end

  private
  def set_person
    @person ||= Person.friendly.find(params[:person_id])
  end

  def person_params
    params.require(:person).permit(:crop_x, :crop_y, :crop_w, :crop_h)
  end
end
