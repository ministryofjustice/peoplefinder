class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  # TODO define the number of question per page
  @@per_page = 5

  def index

    #TODO refactor to not allways call import in the PQ API
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]

    @questions_today = PQ.new_questions.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    @questions_pending_count = PQ.in_progress.count
  end

  def in_progress
    @questions_today_count = PQ.new_questions.count
    @questions_pending = PQ.in_progress.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  def search
  end

  def by_status
    @questions_today = PQ.by_status(params[:qstatus]).paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    @questions_pending_count = PQ.in_progress.count
  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end