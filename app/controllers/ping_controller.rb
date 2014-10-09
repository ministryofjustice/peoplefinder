class PingController  < ActionController::Base
  respond_to :json

  def index
    respond_with Deployment.info
  end
end
