module Api
  class PeopleController < Api::ApplicationController
    before_action :set_person, only: [:show]

    def show
      if @person
        render json: @person
      else
        render json: { error: 'That person was not found' }, status: :not_found
      end
    end

    private

    def set_person
      @person = Person.includes(:groups).find_by(email: params[:email])
    end
  end
end
