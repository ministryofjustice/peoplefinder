module Admin
  class ManagementController < ApplicationController
    before_action :set_search_box_render
    before_action :authorize_user

    def generate_user_behavior_report
      generate CsvPublisher::UserBehaviorReport
      notice :generate_user_behavior_report
      redirect_back(fallback_location: home_path)
    end

    def user_behavior_report
      download(name: __method__)
    end

  private

    def generate(report_klass)
      GenerateReportJob.perform_later(report_klass.to_s)
    end

    def download(name:)
      report = Report.find_by(name:)
      file = report&.to_csv_file

      if file && File.exist?(file)
        send_file(
          file,
          filename: report.client_filename,
          type: report.mime_type,
        )
      else
        warning :file_not_generated
        redirect_back(fallback_location: home_path)
      end
    end

    def serialize(klass)
      {
        "json_class" => klass.name,
      }.to_json
    end

    def set_search_box_render
      @admin_management = true
    end

    def authorize_user
      authorize "Admin::Management".to_sym, "#{action_name}?".to_sym
    end
  end
end
