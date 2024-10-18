class ErrorsController < ApplicationController
  def not_found
    render status: :not_found
  end

  def internal_error
    render status: :internal_server_error
  end
end
