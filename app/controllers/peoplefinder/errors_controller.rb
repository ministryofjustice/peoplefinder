module Peoplefinder
  class ErrorsController < ApplicationController
    layout 'layouts/peoplefinder/home'

    def file_not_found
    end

    def unprocessable
    end

    def internal_server_error
    end
  end
end
