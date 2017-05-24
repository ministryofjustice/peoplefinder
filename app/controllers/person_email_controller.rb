class PersonEmailController < ApplicationController

  include PersonEmailHelper

  before_action :set_person, only: [:edit, :update]
  before_action :set_new_emails, only: [:edit]
  skip_before_action :ensure_user, only: [:edit, :update]

  def edit; end

  def update
    @person.assign_attributes(person_email_params)
    if @person.valid?
      update_and_login @person
    else
      render :edit
    end
  end

  private

  def set_person
    @person = Person.friendly.find(params[:person_id])
  end

  def set_new_emails
    @new_email = params[:new_email]
    @new_secondary_email = alternative_email
  end

  def alternative_email
    @person.secondary_email.blank? ? @person.email : @person.secondary_email
  end

  def person_email_params
    params.require(:person).permit(:email, :secondary_email)
  end

  def update_and_login person
    updater = PersonUpdater.new(person: person,
                                current_user: current_user,
                                state_cookie: StateManagerCookie.new(cookies),
                                session_id: session.id)
    updater.update!
    session.delete(:desired_path)
    notice :profile_email_updated, email: person.email
    login_person person
  end

end
