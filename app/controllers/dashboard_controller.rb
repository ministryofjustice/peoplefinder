class DashboardController < ApplicationController
  before_action :authenticate_user!


  before_filter :load_questions_service

  def index
    @questions = @questions_service.questions()
  end


  def detail
    @question = @questions_service.questions().first
  end

  def search

  end

  protected

  def load_questions_service(service = QuestionsService.new)
    @questions_service ||= service
  end


end