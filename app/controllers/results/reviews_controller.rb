module Results
  class ReviewsController < ApplicationController
    skip_before_action :check_review_period_is_open
    before_action :ensure_participant
    before_action :ensure_review_period_is_closed
    before_action :load_explicit_subject, only: [:index]
    before_action :redirect_unless_user_receives_feedback, only: [:index]

    def index
      @reviews = scope.reviews
    end

  private

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end

    def scope
      @subject || current_user
    end

    def load_explicit_subject
      if params[:user_id]
        @subject = current_user.direct_reports.find(params[:user_id])
      end
      true
    end

    def redirect_unless_user_receives_feedback
      redirect_to results_users_path unless (@subject || current_user).manager
    end
  end
end
