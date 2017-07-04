class GroupUpdateMailer < ActionMailer::Base

  layout 'email'
  add_template_helper MailHelper

  def inform_subscriber(recipient, group, instigator)
    @person = recipient
    @group = group
    @instigator = instigator
    @group_url = group_url(group)
    mail to: recipient.email
  end
end
