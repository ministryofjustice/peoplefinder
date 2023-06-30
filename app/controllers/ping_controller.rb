class PingController < ApplicationController
  protect_from_forgery with: :exception

  def index
    render json: Deployment.info
  end
end
