class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :load_import_service

  # TODO define the number of question per page
  @@per_page = 5

  def index

    #TODO refactor to not allways call import in the PQ API
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]

    at_beginning_of_day = DateTime.now.at_beginning_of_day
    @questions_today = PQ.where('created_at >= ?', at_beginning_of_day).paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    @questions_pending_count = PQ.where('created_at < ?', at_beginning_of_day).count
  end

  def in_progress
    at_beginning_of_day = DateTime.now.at_beginning_of_day
    @questions_today_count = PQ.where('created_at >= ?', at_beginning_of_day).count
    @questions_pending = PQ.where('created_at < ?', at_beginning_of_day).paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
  end

  def search
  end

  def by_status
    result_imported = @import_service.today_questions()
    #@questions = result_imported[:questions]

    at_beginning_of_day = DateTime.now.at_beginning_of_day
    
    
    #@myjoin = PQ.joins(:progress).where('progress.name = unallocated').where('PQ.created_at >= ?', at_beginning_of_day)
    @questions_today = PQ.joins(:progress).where("progresses.name = :search", search: "#{params[:qstatus]}").paginate(:page => params[:page], :per_page => @@per_page).order(:internal_deadline).load
    @questions_pending_count = PQ.where('created_at < ?', at_beginning_of_day).count
    
  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end