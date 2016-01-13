module Api
  class PeopleController < ApplicationController
    before_action :set_person, only: [:show]

    # GET /people/1
    def show
      render json: @person
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.friendly.includes(:groups).find(params[:id])
    end
  end
end
