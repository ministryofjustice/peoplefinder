class PersonImageController < ApplicationController
  before_action :set_person

  def edit
    @image = @person.image
    unless @image.present?
      redirect_to edit_person_path(@person), notice: 'No image has been uploaded for this person'
    end
  end

  private
  def set_person
    @person ||= Person.friendly.find(params[:person_id])
  end
end
