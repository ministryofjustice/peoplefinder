module Results
  class UsersController < ParticipantsController
    skip_before_action :check_review_period_is_open
    before_action :ensure_review_period_is_closed

    def index
      @users = scope.all
    end

    def scope
      current_user.managees
    end

  private

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end
  end
end
