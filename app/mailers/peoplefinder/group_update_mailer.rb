module Peoplefinder
  class GroupUpdateMailer < ActionMailer::Base
    def inform_subscriber(recipient, group, person_responsible)
      @group = group
      @person_responsible = person_responsible
      @group_url = group_url(group)

      mail(to: recipient.email)  do |format|
        format.html { render layout: 'peoplefinder/email' }
        format.text
      end
    end
  end
end
