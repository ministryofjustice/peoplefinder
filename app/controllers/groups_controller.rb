class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

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
    session[:last_group_visited] = @group.id
  end

  # GET /groups/new
  def new
    @group = collection.new
    @group.memberships.build
    load_people
  end

  # GET /groups/1/edit
  def edit
    @group.memberships.build if @group.memberships.empty?
    load_people
  end

  # POST /groups
  def create
    @group = collection.new(group_params)

    if @group.save
      redirect_to @group, notice: "Created #{@group}."
    else
      load_people
      render :new
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      redirect_to @group, notice: "Updated #{@group}"
    else
      load_people
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
    redirect_to groups_url, notice: "Deleted #{@group}."
  end

  def add_membership
    @group = Group.new
    @group.memberships.build
    load_people
    render "add_membership", :layout => false
  end


private
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = collection.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:parent_id, :name, :description, :responsibilities,
      memberships_attributes: [:id, :role, :person_id, :leader])
  end

  def collection
    if params[:group_id]
      Group.friendly.find(params[:group_id]).children
    else
      Group.includes(:parent)
    end
  end

  def load_people
    @people = Person.all
  end
end
