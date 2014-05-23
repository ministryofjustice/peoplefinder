class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  def index
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]
    @questions = PQ.all
  end


  def detail
    result_imported = @import_service.today_questions()
    @question = result_imported[:questions].first
  end

  def search

  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end