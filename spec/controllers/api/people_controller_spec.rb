require "rails_helper"

RSpec.describe Api::PeopleController, type: :controller do
  include PermittedDomainHelper

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:person)
  end

  let(:invalid_attributes) do
    { surname: "" }
  end

  before { create(:group) }

  describe "GET show" do
    subject(:person) { create(:person, valid_attributes) }

    context "with valid auth token" do
      let(:token) { create(:token) }

      before do
        request.headers["AUTHORIZATION"] = token.value
        get :show, params: { id: person.to_param }
      end

      it "assigns the requested person as @person" do
        expect(assigns(:person)).to eq(person)
      end

      it "returns a JSON representation of the person" do
        expect(JSON.parse(response.body)).to eq(JSON.parse(person.to_json))
      end
    end

    context "without valid auth token" do
      before do
        request.headers["AUTHORIZATION"] = "xxxxxxxx"
        get :show, params: { id: person.to_param }
      end

      it "returns status 401" do
        expect(response.status).to eq(401)
      end

      it "returns a JSON error" do
        expect(response.body).to match(/unauthorized/i)
      end
    end
  end
end
