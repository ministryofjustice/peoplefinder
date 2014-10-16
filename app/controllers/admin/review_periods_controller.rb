module Admin
  class ReviewPeriodsController < AdminController
    def update
      ReviewPeriod.closes_at = Time.parse(params[:review_period][:closes_at])
      notice :updated
      redirect_to admin_path
    end
  end
end
