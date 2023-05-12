class ProblemReportMailer < ApplicationMailer
  def problem_report(details_hash)
    problem_report = ProblemReport.new(details_hash)

    set_template('edd53a46-569e-40bf-8639-ceaecabddafd')

    set_personalisation(
      person_email: problem_report.person_email || 'unknown',
      person_id: problem_report.person_id || 'unknown',
      ip_address: problem_report.ip_address,
      browser: problem_report.browser,
      reported_at: problem_report.reported_at.iso8601,
      trying_to_do: problem_report.goal,
      problem: problem_report.problem
    )

    mail(to: Rails.configuration.support_email)
  end
end
