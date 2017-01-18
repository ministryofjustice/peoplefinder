# FIXME: Refactor this controller - it's too long and mailing shouldn't be done in models
class PeopleController < ApplicationController

  before_action :set_person, only: [:show, :edit, :update, :update_email, :destroy]
  before_action :set_org_structure,
    only: [:new, :edit, :create, :update, :add_membership]
  before_action :load_versions, only: [:show]
  before_action :check_and_set_preview_flag, only: [:create, :update]

  # GET /people
  def index
    redirect_to '/'
  end

  # GET /people/1
  def show
    authorize @person
  end

  # GET /people/new
  def new
    @person = Person.new
    authorize @person

    @person.memberships.build
  end

  # GET /people/1/edit
  def edit
    authorize @person

    @activity = params[:activity]
    @person.memberships.build if @person.memberships.empty?
  end

  # POST /people
  def create
    @person = Person.new(person_params)
    authorize @person

    if @preview
      render_with_preview :new
    elsif @person.valid?
      confirm_or_create
    else
      error :create_error
      render :new
    end
  end

  # PATCH/PUT /people/1
  def update
    @person.assign_attributes(person_params)
    authorize @person

    if @preview
      render_with_preview :edit
    elsif @person.valid?
      confirm_or_update
    else
      render :edit
    end
  end

  def update_email
    @person.assign_attributes(person_email_update_params)
    authorize @person
    if @person.valid?
      updater = PersonUpdater.new(@person, current_user)
      updater.update!
      session.delete(:desired_path)
      notice :profile_email_updated, email: @person.email
      login_person @person
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

    render 'add_membership', layout: false
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
      :given_name, :surname, :location_in_building, :building, :city,
      :primary_phone_number, :secondary_phone_number, :pager_number,
      :email, :secondary_email,
      :profile_photo_id, :crop_x, :crop_y, :crop_w, :crop_h,
      :description, :current_project,
      *Person::DAYS_WORKED,
      memberships_attributes: [:id, :role, :group_id, :leader, :subscribed]
    ]
  end

  def person_email_update_params
    params.require(:person).permit(:email)
  end

  def set_org_structure
    @org_structure = Group.hierarchy_hash
  end

  def namesakes?
    return false if params['commit'] == 'Continue'

    @people = Person.namesakes(@person)
    @people.present?
  end

  def render_with_preview action
    @person.crop_profile_photo :preview
    render action
  end

  def confirm_or_create
    if namesakes?
      render(:confirm)
    else
      creator = PersonCreator.new(@person, current_user)
      creator.create!
      notice :profile_created, person: @person
      redirect_to @person
    end
  end

  def confirm_or_update
    if namesakes?
      render(:confirm)
    else
      updater = PersonUpdater.new(@person, current_user)
      updater.update!

      type = @person == current_user ? :mine : :other
      notice :profile_updated, type, person: @person
      redirect_to @person
    end
  end

  def load_versions
    versions = @person.versions
    @last_updated_at = versions.last ? versions.last.created_at : nil
    if super_admin?
      @versions = AuditVersionPresenter.wrap(versions)
    end
  end

  def check_and_set_preview_flag
    @preview = params[:preview].present?
  end
end
