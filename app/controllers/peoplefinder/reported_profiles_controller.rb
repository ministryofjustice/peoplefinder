module Peoplefinder
  class ReportedProfilesController < ApplicationController
    before_action :set_recipient

    def new
      @reported_profile = ReportedProfile.new
    end

    def create
      init_reported_profile

      if @reported_profile.save
        ReminderMailer.reported_profile(@reported_profile).deliver
        notice :message_sent, person: @person
        redirect_to person_path(@person)
      else
        render action: :new
      end
    end

  private

    def set_recipient
      @person = Person.friendly.find(params[:person_id])
    end

    def reported_profile_params
      params.require(:reported_profile).permit(
        :reason_for_reporting, :additional_details
        )
    end

    def init_reported_profile
      @reported_profile = ReportedProfile.new(reported_profile_params)
      @reported_profile.subject = @person
      @reported_profile.recipient_email = @person.support_email
      @reported_profile.notifier = current_user
    end
  end
end
