require "rails_helper"

RSpec.describe SuggestionsController, type: :controller do
  include PermittedDomainHelper

  let(:person_id)  { "person-id" }
  let(:person)     { instance_double(Person) }
  let(:friendly)   { double("friendly") } # rubocop:disable RSpec/VerifiedDoubles

  before do
    mock_logged_in_user
    allow(Person).to receive(:friendly).and_return(friendly)
    allow(friendly).to receive(:find).with(person_id).and_return(person)
    allow(controller).to receive(:authorize).with(person)
  end

  describe "GET new" do
    let(:suggestion) { instance_double(Suggestion) }

    it "assigns a new suggestion as @suggestion" do
      allow(Suggestion).to receive(:new).and_return(suggestion)

      get :new, params: { person_id: }
      expect(assigns(:suggestion)).to eq suggestion
    end

    it "assigns loaded person to @person" do
      allow(Suggestion).to receive(:new).and_return(suggestion)

      get :new, params: { person_id: }
      expect(assigns(:person)).to eq person
    end

    it "checks whether authority to edit person exists" do
      expect(controller).to receive(:authorize).with(person)

      get :new, params: { person_id: }
    end
  end

  describe "POST create" do
    let(:params) { ActionController::Parameters.new(missing_fields: "bar").permit(:missing_fields) }

    describe "invalid suggestion" do
      let(:suggestion) { instance_double(Suggestion, 'valid?': false) }

      it "renders the form" do
        allow(Suggestion).to receive(:new).with(params).and_return(suggestion)
        post :create, params: { person_id: "foo", suggestion: params }
        expect(response).to render_template(:new)
      end
    end

    describe "valid suggestion" do
      let(:suggestion) { instance_double(Suggestion, 'valid?': true) }

      it "delivers the suggestion" do
        allow(Suggestion).to receive(:new).with(params).and_return(suggestion)
        allow(SuggestionDelivery).to receive(:deliver).with(person, current_user, suggestion)

        post :create, params: { person_id:, suggestion: params }

        expect(response).to render_template(:create)
      end

      it "checks whether authority to edit person exists" do
        allow(Suggestion).to receive(:new).with(params).and_return(suggestion)
        allow(SuggestionDelivery).to receive(:deliver).with(person, current_user, suggestion)

        expect(controller).to receive(:authorize).with(person)
        post :create, params: { person_id:, suggestion: params }
      end
    end
  end
end
