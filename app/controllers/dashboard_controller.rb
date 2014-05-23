class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  def index
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]
    @questions = PQ.all
  end


  def detail
    @question = PQ.find_by(uin: params[:uin])
    if !@question.present?
      redirect_to action: 'index'
    end
    @question
  end

  def search

  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end