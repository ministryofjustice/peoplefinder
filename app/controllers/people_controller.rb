class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_action :set_hint_group

  def search
    @people = Person.fuzzy_search(params[:query]).records.limit(100)
  end

  # GET /people
  def index
    @people = Person.all
  end

  # GET /people/1
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to successful_redirect_path, notice: "Created #{@person}’s profile."
    else
      render :new
    end
  end

  # PATCH/PUT /people/1
  def update
    if @person.update(person_params)
      redirect_to successful_redirect_path, notice: "Updated #{@person}’s profile."
    else
      render :edit
    end
  end

  # DELETE /people/1
  def destroy
    @person.destroy
    redirect_to people_url, notice: "Deleted #{@person}’s profile."
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def person_params
    params.require(:person).permit(
      :given_name, :surname, :location, :phone, :mobile, :email, :image,
      :description, *Person::DAYS_WORKED)
  end

  def successful_redirect_path
    person_params[:image].present? ? edit_person_image_path(@person) : @person
  end
end
