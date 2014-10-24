module Peoplefinder
  class InformationRequestsController < ApplicationController
    before_action :set_recipient

    def new
      @information_request = InformationRequest.new(
        recipient: @person,
        message: I18n.t(
          'peoplefinder.controllers.information_requests.default_message',
          recipient: @person,
          sender: current_user)
        )
    end

    def create
      @information_request = InformationRequest.new(information_request_params)
      @information_request.recipient = @person
      @information_request.sender_email = current_user.email

      if @information_request.save
        ReminderMailer.information_request(@information_request).deliver
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

    def information_request_params
      params.require(:information_request).permit(
        :message
        )
    end
  end
end
