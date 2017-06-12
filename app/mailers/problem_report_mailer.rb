class ProblemReportMailer < ActionMailer::Base
  layout 'email'

  def problem_report(details_hash)
    @problem_report = ProblemReport.new(details_hash)
    @firefox_browser_warning = t('.firefox_message', default: '')
    mail to: Rails.configuration.support_email
  end
end
