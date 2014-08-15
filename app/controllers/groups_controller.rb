class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :all_people]
  before_action :redirect_numeric_show, only: [:show]

  # GET /groups
  def index
    @group = Group.departments.first || Group.first
    if @group
      redirect_to @group
    else
      redirect_to new_group_path
    end
  end

  # GET /groups/1
  def show
    respond_to do |format|
      format.html { session[:last_group_visited] = @group.id }
      format.js
    end
  end

  # GET /groups/new
  def new
    @group = collection.new
    @group.memberships.build person: person_from_person_id
  end

  # GET /groups/1/edit
  def edit
    @group.memberships.build if @group.memberships.empty?
  end

  # POST /groups
  def create
    @group = collection.new(group_params)

    if @group.save
      notice :group_created, group: @group
      redirect_to @group
    else
      render :new
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      notice :group_updated, group: @group
      redirect_to @group
    else
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    next_page = @group.parent ? @group.parent : groups_url
    @group.destroy
    notice :group_deleted, group: @group
    redirect_to next_page
  end

private

  def numeric_id?
    params[:id].match(/\A\d+\z/)
  end

  def redirect_numeric_show
    return true unless numeric_id?
    redirect_to @group.canonical_path
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    if numeric_id?
      @group = collection.includes(:people).find(params[:id])
    else
      @group = Group.by_hierarchical_slug(params[:id]).includes(:people).first
    end
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def group_params
    params.require(:group).
      permit(:parent_id, :name, :description, :responsibilities)
  end

  def collection
    if params[:group_id]
      Group.find(params[:group_id]).children
    else
      Group.includes(:parent)
    end
  end

  def person_from_person_id
    params[:person_id] ? Person.friendly.find(params[:person_id]) : nil
  end
end
