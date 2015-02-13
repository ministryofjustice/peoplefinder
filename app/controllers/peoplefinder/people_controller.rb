module Peoplefinder
  # FIXME: Refactor this controller - it's too long and mailing shouldn't be done in models
  # rubocop:disable ClassLength
  class PeopleController < ApplicationController
    before_action :set_person, only: [:show, :edit, :update, :destroy]
    before_action :set_hint_group
    before_action :set_org_structure,
      only: [:new, :edit, :create, :update, :add_membership]
    before_action :load_versions, only: [:show]

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
    end

    # GET /people/1/edit
    def edit
      @person.memberships.build if @person.memberships.empty?
    end

    # POST /people
    def create
      @person = Person.new(person_create_params)

      if @person.valid?
        confirm_or_create
      else
        error :create_error
        render :new
      end
    end

    # PATCH/PUT /people/1
    def update
      @person.assign_attributes(person_update_params)

      if @person.valid?
        confirm_or_update
      else
        render :edit
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
      render 'add_membership', layout: false
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.friendly.includes(:groups).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def person_create_params
      params.require(:person).permit(*person_shared_params_list)
    end

    def person_update_params
      params.require(:person).permit(*(person_shared_params_list - [:email]))
    end

    def person_image_params
      params.require(:person).permit(:image, :image_cache)
    end

    def person_shared_params_list
      [
        :given_name, :surname, :location, :primary_phone_number,
        :secondary_phone_number, :email, :image, :image_cache,
        :description, :tags, :community_id,
        *Person::DAYS_WORKED,
        memberships_attributes: [:id, :role, :group_id, :leader]
      ]
    end

    def successful_redirect_path
      if person_image_params[:image].present? || person_image_params[:image_cache].present?
        edit_person_image_path(@person)
      else
        @person
      end
    end

    def set_org_structure
      @org_structure = Group.arrange.to_h
    end

    def group_from_group_id
      params[:group_id] ? Group.friendly.find(params[:group_id]) : nil
    end

    def namesakes?
      return false if params['commit'] == 'Continue'

      @people = Person.namesakes(@person)
      @people.present?
    end

    def confirm_or_create
      if namesakes?
        render(:confirm)
      else
        @person.save
        @person.send_create_email!(current_user)
        notice :profile_created, person: @person
        redirect_to successful_redirect_path
      end
    end

    def confirm_or_update
      if namesakes?
        render(:confirm)
      else
        @person.save
        @person.send_update_email!(current_user)

        type = @person == current_user ? :mine : :other
        notice :profile_updated, type, person: @person
        redirect_to successful_redirect_path
      end
    end

    def load_versions
      if super_admin?
        @versions = AuditVersionPresenter.wrap(@person.versions)
      end
    end
  end
end
