module Admin
  class ManagementController < ApplicationController
    before_action :set_search_box_render
    before_action :authorize_user

    def generate_user_behavior_report
      report = serialize(CsvPublisher::UserBehaviorReport)
      GenerateReportJob.perform_later(report)
      notice :generate_user_behavior_report
      redirect_to :back
    end

    def user_behavior_report
      file = CsvPublisher::UserBehaviorReport.default_file_path
      download(file: file, name: __method__)
    end

    private

    def download file:, name:
      if File.exist? file
        send_file(
          file,
          filename: "#{name}_#{Date.current.strftime('%d-%m-%Y')}.csv",
          type: 'text/csv'
        )
      else
        warning :file_not_generated
        redirect_to :back
      end
    end

    def serialize klass
      {
        'json_class' => klass.name
      }.to_json
    end

    def set_search_box_render
      @admin_management = true
    end

    def authorize_user
      authorize 'Admin::Management'.to_sym, "#{action_name}?".to_sym
    end
  end
end
