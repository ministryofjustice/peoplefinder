module Peoplefinder
  module Api
    class ApplicationController < ActionController::Base
      before_action :authenticate!

    private

      def authenticate!
        token = Token.where(value: authorization_token).first
        unless token
          render json: { errors: 'Unauthorized' }, status: :unauthorized
        end
      end

      def authorization_token
        request.headers['AUTHORIZATION'] || params[:token]
      end
    end
  end
end
