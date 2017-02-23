module Admin
  class ManagementController < ApplicationController
    before_action :set_search_box_render

    def show
    end

    def user_behavior_report
      @file = CsvPublisher::UserBehaviorReport.new.publish!
      send_file(
        @file,
        filename: "user_behaviour_report_#{Date.current.strftime('%d-%m-%Y')}.csv",
        type: 'text/csv'
      )
    end

    def set_search_box_render
      @admin_management = true
    end
  end
end
