class AuditsController < ApplicationController
  def index
    @versions = PaperTrail::Version.order(created_at: :desc).paginate(:page => params[:page], :per_page => 200)
  end

  def undo
    @version = PaperTrail::Version.find(params[:id])
    if @version.event == 'create'
      @version.item.destroy
    else
      @version.reify.save
    end
    redirect_to :action => :index
  end
end
