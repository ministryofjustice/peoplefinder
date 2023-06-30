# FIXME: Refactor this controller - it's too long
class PeopleController < ApplicationController
  include StateCookieHelper

  before_action :set_person, only: %i[show edit update destroy]
  before_action :set_org_structure, only: %i[new edit create update add_membership]
  before_action :load_versions, only: [:show]

  # GET /people
  def index
    redirect_to "/"
  end

  # GET /people/1
  def show
    authorize @person
    delete_state_cookie
  end

  # GET /people/new
  def new
    @person = Person.new
    build_membership @person
    authorize @person
  end

  # GET /people/1/edit
  def edit
    authorize @person
    @activity = params[:activity]
    build_membership @person
  end

  # POST /people
  def create
    set_state_cookie_action_create
    set_state_cookie_phase_from_button

    @person = Person.new(person_params)
    authorize @person

    if @person.valid?
      confirm_or_create
    else
      build_membership @person
      render :new
    end
  end

  # PATCH/PUT /people/1
  def update
    set_state_cookie_action_update_if_not_create
    set_state_cookie_phase_from_button
    @person.assign_attributes(person_params)
    authorize @person

    if @person.valid?
      confirm_or_update
    else
      render :edit
    end
  end

  # DELETE /people/1
  def destroy
    authorize @person

    destroyer = PersonDestroyer.new(@person, current_user)
    destroyer.destroy!
    notice :profile_deleted, person: @person
    group = @person.groups.first

    redirect_to group ? group_path(group) : home_path
  end

  def add_membership
    set_person if params[:id].present?
    @person ||= Person.new
    authorize @person

    render "add_membership", layout: false
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.friendly.includes(:groups).find(params[:id])
  end

  def person_params
    params.require(:person).permit(*person_params_list)
  end

  def person_params_list
    [
      :given_name,
      :surname,
      :location_in_building,
      :building,
      :city,
      :primary_phone_number,
      :secondary_phone_number,
      :pager_number,
      :email,
      :secondary_email,
      :swap_email_display,
      :profile_photo_id,
      :crop_x,
      :crop_y,
      :crop_w,
      :crop_h,
      :description,
      :current_project,
      *Person::DAYS_WORKED,
      { memberships_attributes: %i[id role group_id leader subscribed _destroy] },
    ]
  end

  def set_org_structure
    @org_structure = Group.hierarchy_hash
  end

  def build_membership(person)
    person.memberships.build if person.memberships.blank?
  end

  def namesakes?
    return false if params["continue_from_duplication"].present?

    @people = Person.namesakes(@person)
    @people.present?
  end

  def namesakes_check_required_and_found?
    namesakes? if @person.changes.keys.any? { |key| %w[email surname given_name].include? key }
  end

  def confirm_or_create
    if namesakes?
      render(:confirm)
    else
      creator = PersonCreator.new(@person, current_user, StateManagerCookie.new(cookies), session.id)
      creator.create!
      notice(:profile_created, **{ person: @person }) if state_cookie_saving_profile?
      redirect_to redirection_destination
    end
  end

  def confirm_or_update
    if namesakes_check_required_and_found?
      render(:confirm)
    else

      updater = PersonUpdater.new(person: @person,
                                  current_user:,
                                  state_cookie: StateManagerCookie.new(cookies),
                                  session_id: session.id)
      updater.update!
      type = @person == current_user ? :mine : :other
      notice(:profile_updated, type, **{ person: @person.to_s }) if state_cookie_saving_profile?
      redirect_to redirection_destination
    end
  end

  def redirection_destination
    if state_cookie_editing_picture?
      edit_person_image_path(@person)
    elsif state_cookie_editing_picture_done?
      edit_person_path(@person)
    else
      @person
    end
  end

  def load_versions
    versions = @person.versions
    @last_updated_at = versions.last&.created_at
    if super_admin?
      @versions = AuditVersionPresenter.wrap(versions)
    end
  end
end
