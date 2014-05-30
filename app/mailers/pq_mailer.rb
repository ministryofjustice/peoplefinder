class PqMailer < ActionMailer::Base
  default from: "from@example.com"
  def commit_email(action_officer,pq)
    @action_officer = action_officer
    @pq = pq
    @url  = 'http://moj.pq.io/token/'
    mail(to: @action_officer.email, subject: 'You have been allocated a question')
  end
end
