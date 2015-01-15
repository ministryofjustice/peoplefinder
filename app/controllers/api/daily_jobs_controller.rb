module Api
  class DailyJobsController < ApiController
    def create
      logger.info "Enqueuing RemindersJob"
      RemindersJob.perform_later
      render json: { 'status' => 'ok' }
    end
  end
end
