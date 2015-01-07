module Api
  class DailyJobsController < ApiController
    def create
      RemindersJob.perform_later
      render json: { 'status' => 'ok' }
    end
  end
end
