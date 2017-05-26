class PersonEmailController < ApplicationController

  include PersonEmailHelper

  before_action :set_person_and_auth, only: [:edit, :update]
  before_action :set_new_emails_from_auth, only: [:edit]
  skip_before_action :ensure_user, only: [:edit, :update]

  def edit
    not_found unless authenticated_login?
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

  def set_person_and_auth
    @person = Person.friendly.find(params[:person_id])
    @token = find_token(params[:token_value])
    @oauth_hash = params[:oauth_hash]
  end

  def authenticated_login?
    @token&.within_validity_period? || @oauth_hash.present?
  end

  def set_new_emails_from_auth
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

  def find_token token_value
    # OPTIMIZE: duplicate - see token_login service class
    Token.find_each do |token|
      return token if Secure.compare(token.value, token_value)
    end
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def auth_hash
    request.env['omniauth.auth']
  end

end
