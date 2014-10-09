module Peoplefinder
  class VersionsController < ApplicationController
    def index
      @versions = Version.order(created_at: :desc).
        paginate(page: params[:page], per_page: 200)
    end

    def undo
      @version = Version.find(params[:id])
      @version.undo
      redirect_to action: :index
    end
  end
end
