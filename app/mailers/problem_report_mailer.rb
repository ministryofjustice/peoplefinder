class ProblemReportMailer < ActionMailer::Base
  layout 'email'

  def problem_report(details_hash)
    @problem_report = ProblemReport.new(details_hash)
    mail to: Rails.configuration.support_email
  end
end
