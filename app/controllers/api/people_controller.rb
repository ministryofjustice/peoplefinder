module Api
  class PeopleController < Api::ApplicationController
    before_action :set_person, only: [:show]

    def show
      render json: @person
    end

    private

    def set_person
      @person = Person.includes(:groups).find_by(email: params[:email])
    end
  end
end
