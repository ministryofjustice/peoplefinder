class InformationRequestsController < ApplicationController
  before_action :set_recipient

  def new
    @information_request = InformationRequest.new(
      recipient: @person,
      message: "Hello #{ @person }
                \nI would like you to update your People Finder profile.
                \nThanks,\n#{current_user}"
      )
  end

  def create
    @information_request = InformationRequest.new(information_request_params)
    @information_request.recipient = @person
    @information_request.sender_email = current_user.email

    if @information_request.save
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
