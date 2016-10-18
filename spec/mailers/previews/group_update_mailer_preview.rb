class GroupUpdateMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def inform_subscriber_email
    GroupUpdateMailer.inform_subscriber(recipient, team, instigator)
  end
end