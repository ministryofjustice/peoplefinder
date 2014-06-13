class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  def index

    #TODO refactor to not allways call import in the PQ API
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]

    at_beginning_of_day = DateTime.now.at_beginning_of_day
    @questions_today = PQ.where('created_at >= ?', at_beginning_of_day).order(:internal_deadline).load

    @questions_pending = PQ.where('created_at < ?', at_beginning_of_day).order(:internal_deadline).load

  end

  def search

  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end