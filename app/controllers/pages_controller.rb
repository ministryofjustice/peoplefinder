class PagesController < ApplicationController
  skip_before_action :ensure_user

  def show
    @page_name = params[:id]
  end
end
