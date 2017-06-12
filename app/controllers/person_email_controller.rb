class PersonEmailController < ApplicationController

  include PersonEmailHelper

  skip_before_action :ensure_user, only: [:edit, :update]
  before_action :set_person, :set_auth, :ensure_auth, only: [:edit, :update]
  before_action :set_new_emails, only: [:edit]

  def edit
    warning :person_email_confirm
  end

  def update
    @person.assign_attributes(person_email_params)
    if @person.valid?
      update_and_login @person
    else
      render :edit
    end
  end

  private

  def token_value
    params[:token_value] || params.dig(:person, :token_value)
  end

  def oauth_hash
    params[:oauth_hash] || params.dig(:person, :oauth_hash)
  end

  def set_person
    @person = Person.friendly.find(params[:person_id])
  end

  def set_auth
    @token = Token.find_securely(token_value)
    @oauth_hash = oauth_hash
  end

  def ensure_auth
    not_found unless authenticated?
  end

  def authenticated?
    @token&.within_validity_period? || @oauth_hash.present?
  end

  def set_new_emails
    @new_email = new_email
    @new_secondary_email = alternative_email
  end

  def new_email
    if @token.present?
      @token&.user_email
    elsif @oauth_hash.present?
      @oauth_hash&.dig(:info, :email)
    end
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

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

end
