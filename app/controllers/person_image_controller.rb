class PersonImageController < ApplicationController

  def edit
    @person = Person.find_by(slug: params[:person_id])
  end
end
