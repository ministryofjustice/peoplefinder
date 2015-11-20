class ProblemReportsController < ApplicationController
  skip_before_action :ensure_user

  def create
    problem_report = ProblemReport.new(problem_report_params)
    ProblemReportMailer.problem_report(problem_report.to_hash).deliver_later
    redirect_to :back
  end

private

  def problem_report_params
    params.require(:problem_report).
      permit(:goal, :problem, :browser, :person_email).
      merge(current_user_params).
      merge(ip_address: request.remote_ip)
  end

  def current_user_params
    if logged_in_regular?
      { person_email: current_user.email, person_id: current_user.id }
    else
      {}
    end
  end
end
