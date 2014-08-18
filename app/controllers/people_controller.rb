class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :set_hint_group

  def search
    @people = Person.fuzzy_search(params[:query]).records.limit(100)
  end

  # GET /people
  def index
    redirect_to '/'
  end

  # GET /people/1
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
    @person.memberships.build group: group_from_group_id
    set_groups
  end

  # GET /people/1/edit
  def edit
    @person.memberships.build if @person.memberships.empty?
    set_groups
  end

  # POST /people
  def create
    @person = Person.new(person_params)

    if @person.valid?
      duplicate_people ? render(:confirm) : create_and_redirect
    else
      set_groups && render(:new)
    end
  end

  # PATCH/PUT /people/1
  def update
    @old_email = @person.email
    @person.assign_attributes(person_params)

    if @person.valid?
      duplicate_people ? render(:confirm) : update_and_redirect
    else
      set_groups && render(:edit)
    end
  end

  # DELETE /people/1
  def destroy
    @person.send_destroy_email!(current_user)
    @person.destroy
    notice :profile_deleted, person: @person
    redirect_to home_path
  end

  def add_membership
    set_person if params[:id].present?
    @person ||= Person.new
    set_groups
    render 'add_membership', layout: false
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.friendly.includes(:groups).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def person_params
    params.require(:person).permit(
      :given_name, :surname, :location, :primary_phone_number,
      :secondary_phone_number, :email, :image, :image_cache,
      :description,
      *Person::DAYS_WORKED,
      memberships_attributes: [:id, :role, :group_id, :leader])
  end

  def successful_redirect_path
    if person_params[:image].present? || person_params[:image_cache].present?
      edit_person_image_path(@person)
    else
      @person
    end
  end

  def set_groups
    @groups = Group.all
  end

  def group_from_group_id
    params[:group_id] ? Group.friendly.find(params[:group_id]) : nil
  end

  def duplicate_people
    return false if params['commit'] == 'Continue'

    @people = Person.
      where(surname: @person.surname).
      where(given_name: @person.given_name).
      where.not(id: @person.id)
    @people.present?
  end

  def create_and_redirect
    @person.save
    @person.send_create_email!(current_user)
    notice :profile_created, person: @person
    redirect_to successful_redirect_path
  end

  def update_and_redirect
    @person.save
    @person.send_update_email!(current_user, @old_email)
    notice :profile_updated, person: @person
    redirect_to successful_redirect_path
  end
end
