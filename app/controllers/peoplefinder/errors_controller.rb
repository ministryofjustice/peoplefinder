require 'peoplefinder'

class Peoplefinder::ErrorsController < ApplicationController
  layout 'peoplefinder/layouts/home'
  def file_not_found
  end

  def unprocessable
  end

  def internal_server_error
  end
end
