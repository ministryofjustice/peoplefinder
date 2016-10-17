class ProblemReportMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def problem_report_email
    ProblemReportMailer.problem_report problem_details
  end

  private

  def problem_details
    {
      goal: 'Something daft',
      problem: 'It broke',
      ip_address: '255.255.255.255',
      person_email: recipient.email,
      person_id: recipient.id,
      browser: 'IE99',
      timestamp: Time.now
    }
  end

end
