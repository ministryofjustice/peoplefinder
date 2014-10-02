module Results
  class UsersController < ApplicationController
    skip_before_action :check_review_period_is_open
    before_action :ensure_participant
    before_action :ensure_review_period_is_closed

    def index
      show_tabs
      @users = scope.all
    end

  private

    def scope
      current_user.direct_reports
    end

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end
  end
end
