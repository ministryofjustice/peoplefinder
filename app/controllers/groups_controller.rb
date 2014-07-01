class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  def index
    @groups = collection.all
  end

  # GET /groups/1
  def show
  end

  # GET /groups/new
  def new
    @group = collection.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  def create
    @group = collection.new(group_params)

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully destroyed.'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = collection.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:parent_id, :name, :description, :responsibilities)
  end

  def collection
    if params[:group_id]
      Group.friendly.find(params[:group_id]).children
    else
      Group.includes(:parent)
    end
  end
end
