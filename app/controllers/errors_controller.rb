class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.any { head :not_found }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.any { head :internal_server_error }
    end
  end
end
