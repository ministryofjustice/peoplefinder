class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :ensure_user
  skip_before_action :check_review_period_is_open
  before_action :verify_api_key

private

  def forbidden
    render json: { 'status' => 'forbidden' }, status: :forbidden
    false
  end

  def verify_api_key
    forbidden unless params['key'] == ENV.fetch('API_KEY')
  end
end
