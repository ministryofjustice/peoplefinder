class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  def index
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]
    @questions = PQ.order(:internal_deadline).all
  end

  def search

  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end