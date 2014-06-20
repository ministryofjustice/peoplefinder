class AuditsController < ApplicationController
  def index
    @versions = PaperTrail::Version.order(created_at: :desc).paginate(:page => params[:page], :per_page => 200)
  end
end