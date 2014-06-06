class WatchlistMembersController < ApplicationController
  before_action :set_watchlist_member, only: [:show, :edit, :update, :destroy]

  # GET /watchlist_members
  # GET /watchlist_members.json
  def index
    @watchlist_members = WatchlistMember.all
  end

  # GET /watchlist_members/1
  # GET /watchlist_members/1.json
  def show
  end

  # GET /watchlist_members/new
  def new
    @watchlist_member = WatchlistMember.new
  end

  # GET /watchlist_members/1/edit
  def edit
  end

  # POST /watchlist_members
  # POST /watchlist_members.json
  def create
    @watchlist_member = WatchlistMember.new(watchlist_member_params)

    respond_to do |format|
      if @watchlist_member.save
        format.html { redirect_to @watchlist_member, notice: 'Watchlist member was successfully created.' }
        format.json { render action: 'show', status: :created, location: @watchlist_member }
      else
        format.html { render action: 'new' }
        format.json { render json: @watchlist_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /watchlist_members/1
  # PATCH/PUT /watchlist_members/1.json
  def update
    respond_to do |format|
      if @watchlist_member.update(watchlist_member_params)
        format.html { redirect_to @watchlist_member, notice: 'Watchlist member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @watchlist_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /watchlist_members/1
  # DELETE /watchlist_members/1.json
  def destroy
    @watchlist_member.destroy
    respond_to do |format|
      format.html { redirect_to watchlist_members_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_watchlist_member
      @watchlist_member = WatchlistMember.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def watchlist_member_params
      params.require(:watchlist_member).permit(:name, :email, :deleted)
    end
end
