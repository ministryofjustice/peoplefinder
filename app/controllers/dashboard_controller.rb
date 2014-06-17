class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  # TODO define the number of question per page
  @@per_page = 5

  def index

    #TODO refactor to not allways call import in the PQ API
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]

    @questions = PQ.new_questions.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  def in_progress
    @questions = PQ.in_progress.paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  def search
  end

  def by_status
    @questions = PQ.by_status(params[:qstatus]).paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end