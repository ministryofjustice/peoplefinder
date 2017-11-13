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
    redirect_back fallback_location: '/'
  end

  def zendesk_client
    ZendeskAPI::Client.new do |config|
      config.url = ENV['ZD_URL']
      config.username = ENV['ZD_USER']
      config.password = ENV['ZD_PASS']
      config.enable_http = true
      config.retry = true
      require 'logger'
      config.logger = Logger.new(STDOUT)
    end
  end

  def zendesk_request_fields
    [{
      id: '114101595573', value: params['problem_report_goal']
    }, {
      id: '114101595593', value: params['problem_report_problem']
    }, {
      id: '114101595613', value: params['problem_report_origin']
    }, {
      id: '114101582834', value: params['problem_report_browser']
    }]
  end
end
