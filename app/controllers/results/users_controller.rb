module Results
  class UsersController < ApplicationController
    skip_before_action :check_review_period_is_open
    before_action :ensure_participant
    before_action :ensure_review_period_is_closed

    def index
      respond_to do |format|
        format.html { render_index_html }
        format.csv { render_index_csv }
      end
    end

  private

    def render_index_html
      show_tabs
      @users = users.all
    end

    def render_index_csv
      csv = MultiUserCSVRenderer.new(users.all).to_csv
      send_data csv, filename: "reviews.csv", disposition: 'attachment'
    end

    def users
      current_user.direct_reports
    end

    def ensure_review_period_is_closed
      forbidden unless review_period_closed?
    end
  end
end
