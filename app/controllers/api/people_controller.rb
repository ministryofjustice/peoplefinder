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
      @person = Person.find_by(internal_auth_key: params[:email])
      return if @person

      auth_user_email = AuthUserLoader.find_auth_email(params[:email])
      @person = Person.find_by(internal_auth_key: auth_user_email) if auth_user_email
    end
  end
end
