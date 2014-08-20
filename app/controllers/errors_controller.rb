class ErrorsController < ApplicationController
  layout 'home'
  def file_not_found
  end

  def unprocessable
  end

  def internal_server_error
  end
end
