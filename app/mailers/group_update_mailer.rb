class GroupUpdateMailer < ActionMailer::Base
  layout 'email'

  def inform_subscriber(recipient, group, person_responsible)
    @group = group
    @person_responsible = person_responsible
    @group_url = group_url(group)
    @firefox_browser_warning = t('.firefox_message')
    mail to: recipient.email
  end
end
