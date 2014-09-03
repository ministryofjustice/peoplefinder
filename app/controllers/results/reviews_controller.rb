module  Results
  class ReviewsController < ApplicationController
    skip_before_action :check_review_period_is_open
    before_action :ensure_review_period_is_closed

    def index
      @reviews = current_user.reviews
    end

  private

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end
  end
end
