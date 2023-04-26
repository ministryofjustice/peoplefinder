class GroupUpdateMailer < ApplicationMailer
  helper MailHelper

  def inform_subscriber(recipient, group, instigator)
    @person = recipient
    @group = group
    @instigator = instigator
    @group_url = group_url(group)
    sendmail(to: recipient.email)
  end
end
