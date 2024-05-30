# frozen_string_literal: true

class ExternalUsersController
  include StateCookieHelper

  before_action :set_external_user, only: %i[show edit update destroy]
  before_action :load_versions, only: [:show]

  # GET /external_user
  def index
    redirect_to "/"
  end

  # GET /external_user/1
  def show
    authorize @external_user
    delete_state_cookie
  end

  # GET /external_user/new
  def new
    @external_user = external_user.new
    authorize @external_user
  end

  # GET /external_user/1/edit
  def edit
    authorize @external_user
    @external_user = params[:activity]
  end

  # POST /external_user
  def create
    set_state_cookie_action_create
    set_state_cookie_phase_from_button

    @external_user = external_user.new(external_user_params)
    authorize @external_user

    if @external_user.valid?
      confirm_or_create
    else
      render :new
    end
  end

  # PATCH/PUT /external_user/1
  def update
    set_state_cookie_action_update_if_not_create
    set_state_cookie_phase_from_button
    external_user.assign_attributes(external_user_params)
    authorize @external_user

    if @external_user.valid?
      confirm_or_update
    else
      render :edit
    end
  end

  # DELETE /external_user/1
  def destroy
    authorize @external_user

    destroyer = ExternalUserDestroyer.new(@external_user, current_user)
    destroyer.destroy!

    notice :profile_deleted, person: @external_user
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_external_user
    @external_user = external_user.find(params[:id])
  end

  def external_user_params
    params.require(:external_user).permit(*external_user_params_list)
  end

  def external_user_params_list
    %i[
      given_name
      surname
      email
      company
      admin
    ]
  end
end
