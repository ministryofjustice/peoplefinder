class ReportController < ApplicationController
  require 'zendesk_api'
  require 'json'

  def index
    client = zendesk_client
    client.tickets.create(
      subject: "Website error submission #{Time.current}",
      comment: { value: params['problem_report_problem'] },
      submitter_id: client.current_user.id,
      priority: 'normal', type: 'incident', custom_fields: zendesk_request_fields
    )
    flash[:notice] = 'Thank you for your submission. Your problem has been reported.'
    redirect_to_referrer
  end

  def zendesk_client
    ZendeskAPI::Client.new do |config|
      config.url = ENV['ZD_URL']
      config.username = ENV['ZD_USER']
      config.password = ENV['ZD_PASS']
      config.retry = true
      require 'logger'
      config.logger = Logger.new(STDOUT)
    end
  end

  def zendesk_request_fields
    [
      { id: '45490089', value: params['problem_report_goal'] },
      { id: '45522325', value: params['problem_report_problem'] },
      { id: '45522345', value: params['problem_report_origin'] },
      { id: '34146805', value: params['problem_report_browser'] },
      { id: '45522485', value: params['problem_report_email'] }
    ]
  end

  def redirect_to_referrer
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end
end
