class PingController < ActionController::Base
  def index
    render json: Deployment.info
  end
end
