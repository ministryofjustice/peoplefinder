class SessionsController < ApplicationController
  skip_before_filter :ensure_user

  def create
    email = auth_hash['info']['email']
    # Although the user should only be able to select from these two domains,
    # still good to check manually in case someone hacks the HTML post.
    if email.match(/@(digital.justice.gov.uk|digital.cabinet-office.gov.uk)$/)
      session['current_user'] = email
      redirect_to '/'
    else
      session['current_user'] = nil
      render :text => "You need to sign in with a MOJ DS or GDS account"
    end
  end

  def new

  end

  def destroy
    session['current_user'] = nil
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
