class PersonMembershipsController < ApplicationController
  before_action :set_person
  before_action :set_membership, only: [:show, :edit, :update, :destroy]
  before_action :set_candidates, only: [:new, :edit]

  # GET /memberships
  def index
    @memberships = collection.all
  end

  # GET /memberships/1
  def show
  end

  # GET /memberships/new
  def new
    @membership = collection.new
  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  def create
    @membership = collection.new(membership_params)

    if @membership.save
      redirect_to person_memberships_path(@person), notice: 'Membership was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /memberships/1
  def update
    if @membership.update(membership_params)
      redirect_to person_memberships_path(@person), notice: 'Membership was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /memberships/1
  def destroy
    @membership.destroy
    redirect_to person_memberships_path(@person), notice: 'Membership was successfully destroyed.'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_membership
    @membership = collection.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def membership_params
    params.require(:membership).permit(:role, :group_id, :leader)
  end

  def collection
    @person.memberships.includes(:group)
  end

  def set_person
    @person ||= Person.friendly.find(params[:person_id])
  end

  def set_candidates
    if @membership
      existing_memberships = @person.memberships.where.not(id: @membership.id)
    else
      existing_memberships = @person.memberships
    end
    @candidates = Group.where.not(id: existing_memberships.pluck(:group_id))
  end
end
