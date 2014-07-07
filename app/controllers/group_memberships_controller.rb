class GroupMembershipsController < ApplicationController
  before_action :set_group
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

    # => validation on create has been disabled
    # => to facilitate the nested membership form
    # => on the edit person page.
    # => Adding some validation logic to ensure
    # => this method behaves correctly, until
    # => this controller is removed.

    if @membership.person_id.blank?
      @membership.errors.add(:person, 'cannot be blank')
      render :new

    elsif @membership.save
      redirect_to group_memberships_path(@group),
        notice: "Added #{@membership.person} to #{@group}."

    else
      render :new
    end
  end

  # PATCH/PUT /memberships/1
  def update
    if @membership.update(membership_params)
      redirect_to group_memberships_path(@group),
        notice: "Updated details."
    else
      render :edit
    end
  end

  # DELETE /memberships/1
  def destroy
    @membership.destroy
    redirect_to group_memberships_path(@group),
        notice: "Removed #{@membership.person} from #{@group}."
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_membership
    @membership = collection.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def membership_params
    params.require(:membership).permit(:role, :person_id, :leader)
  end

  def collection
    @group.memberships.includes(:person)
  end

  def set_group
    @group ||= Group.friendly.find(params[:group_id])
  end

  def set_candidates
    if @membership
      existing_memberships = @group.memberships.where.not(id: @membership.id)
    else
      existing_memberships = @group.memberships
    end
    @candidates = Person.where.not(id: existing_memberships.pluck(:person_id)).
      sort_by { |p| p.name }
  end
end
