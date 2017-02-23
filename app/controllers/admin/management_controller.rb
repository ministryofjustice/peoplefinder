module Admin
  class ManagementController < ApplicationController
    before_action :set_search_box_render
    before_action :authorize_user

    def user_behavior_report
      @file = CsvPublisher::UserBehaviorReport.new.publish!
      send_file(
        @file,
        filename: "user_behaviour_report_#{Date.current.strftime('%d-%m-%Y')}.csv",
        type: 'text/csv'
      )
    end

    private

    def set_search_box_render
      @admin_management = true
    end

    def authorize_user
      authorize 'Admin::Management'.to_sym, "#{action_name}?".to_sym
    end
  end
end
