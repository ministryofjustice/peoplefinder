class PagesController < ApplicationController
  def show
    @page_name = params[:id]
  end
end
