class PersonDeletionRequestController < ApplicationController

  before_action :set_person

  def new; end

  def create
    PersonDeletionRequestMailer.deletion_request(
      reporter: current_user,
      person: @person,
      note: params[:note]
    ).deliver_now

    notice(:request_sent)
    redirect_to person_path(@person)
  end

  private

  def set_person
    @person = Person.friendly.find(params[:person_id])
  end

end
