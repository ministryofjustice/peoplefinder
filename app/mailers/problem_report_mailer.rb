class ProblemReportMailer < ApplicationMailer
  def problem_report(details_hash)
    @problem_report = ProblemReport.new(details_hash)
    sendmail to: Rails.configuration.support_email,
      reply_to: @problem_report.person_email
  end
end
