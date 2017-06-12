class GroupsController < ApplicationController
  before_action :set_group, only: [
    :show, :edit, :update, :destroy, :all_people, :people_outside_subteams, :organogram
  ]
  before_action :set_org_structure, only: [:new, :edit, :create, :update]
  before_action :load_versions, only: [:show]

  # GET /groups
  def index
    @group = Group.department || Group.first
    if @group
      redirect_to @group
    else
      redirect_to new_group_path
    end
  end

  # GET /groups/1
  def show
    authorize @group
    @all_people_count = @group.all_people_count
    @people_outside_subteams_count = @group.people_outside_subteams_count

    respond_to do |format|
      format.html { session[:last_group_visited] = @group.id }
      format.js
    end
  end

  # GET /teams/slug_or_id/people
  def all_people
    @people_in_subtree = @group.all_people.paginate(page: params[:page], per_page: 500)
  end

  # GET /teams/slug_or_id/organogram
  def organogram
  end

  # GET /groups/new
  def new
    @group = collection.new
    @group.memberships.build person: person_from_person_id
    authorize @group
  end

  # GET /groups/1/edit
  def edit
    @group.memberships.build if @group.memberships.empty?
    authorize @group
  end

  # POST /groups
  def create
    @group = collection.new(group_params)
    authorize @group

    respond_to do |format|
      if @group.save
        create_success_response(format)
      else
        create_failure_response(format)
      end
    end
  end

  # PATCH/PUT /groups/1
  def update
    authorize @group

    group_update_service = GroupUpdateService.new(
      group: @group, person_responsible: current_user
    )
    if group_update_service.update(group_params)
      notice :group_updated, group: @group
      redirect_to @group
    else
      # error :update_error
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    authorize @group

    next_page = @group.parent ? group_path(@group.parent) : groups_path
    @group.destroy
    notice :group_deleted, group: @group
    redirect_to next_page
  end

  private

  def create_success_response format
    format.html do
      notice :group_created, group: @group
      redirect_to @group
    end
    format.json do
      render json: @group.as_json(methods: :parent_id), status: :created, location: @group
    end
  end

  def create_failure_response format
    format.html do
      # error :create_error
      render :new
    end
    format.json do
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    group = collection.friendly.find(params[:id])
    @group = Group.includes(:people).find(group.id)
  end

  def set_org_structure
    @org_structure = Group.hierarchy_hash
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def group_params
    params.require(:group).
      permit(:parent_id, :name, :acronym, :description)
  end

  def collection
    if params[:group_id]
      Group.friendly.find(params[:group_id]).children
    else
      Group
    end
  end

  def person_from_person_id
    params[:person_id] ? Person.friendly.find(params[:person_id]) : nil
  end

  def load_versions
    versions = @group.versions
    @last_updated_at = versions.last ? versions.last.created_at : nil
    if super_admin?
      @versions = AuditVersionPresenter.wrap(versions)
    end
  end

  def can_add_person_here?
    @group && @group.ancestry_depth > 1
  end
end
