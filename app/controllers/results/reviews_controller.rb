module Results
  class ReviewsController < ApplicationController
    skip_before_action :check_review_period_is_open
    before_action :ensure_participant
    before_action :ensure_review_period_is_closed
    before_action :load_scoped_subject, only: [:index]
    before_action :redirect_unless_user_receives_feedback, only: [:index]

    def index
      respond_to do |format|
        format.html { render_index_html }
        format.csv { render_index_csv }
      end
    end

  private

    def render_index_html
      show_tabs unless scoped_by_subject?
      @review_aggregator = ReviewAggregator.new(user.reviews)
    end

    def render_index_csv
      renderer = UserCSVRenderer.new(user)
      send_data renderer.to_csv,
        filename: "reviews-#{user.id}.csv",
        disposition: 'attachment'
    end

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end

    def user
      @subject || current_user
    end

    def redirect_unless_user_receives_feedback
      redirect_to results_users_path unless (@subject || current_user).manager
    end
  end
end
