module Results
  class ReviewsController < ApplicationController
    skip_before_action :check_review_period_is_open
    before_action :ensure_participant
    before_action :ensure_review_period_is_closed
    before_action :load_scoped_subject, only: [:index]
    before_action :redirect_unless_user_receives_feedback, only: [:index]

    def index
      @review_aggregator = ReviewAggregator.new(scope.reviews)
      suppress_tabs if scoped_by_subject?
    end

  private

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end

    def scope
      @subject || current_user
    end

    def redirect_unless_user_receives_feedback
      redirect_to results_users_path unless (@subject || current_user).manager
    end
  end
end
