require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  include PermittedDomainHelper

  let(:person) { create(:person, given_name: "John", surname: "Doe", email: "john.doe@digital.justice.gov.uk") }

  it_behaves_like "session_person_creatable"

  describe "GET new" do
    context "with supported browser" do
      before do
        allow_any_instance_of(described_class).to receive(:supported_browser?).and_return true
        get :new
      end

      it "renders new" do
        expect(response).to render_template :new
      end
    end

    context "with unsupported browser" do
      before do
        allow_any_instance_of(described_class).to receive(:supported_browser?).and_return false
        get :new
      end

      it "redirects to warning page" do
        expect(response).to redirect_to unsupported_browser_new_sessions_path
      end
    end
  end

  describe "POST create_person" do
    let(:person_params) do
      {
        person: {
          email: "fred.bloggs@digital.justice.gov.uk",
          given_name: "Fred",
          surname: "Bloggs",
        },
      }
    end

    it "creates the new person" do
      expect { post :create_person, params: person_params }.to change Person, :count
    end

    it "redirects to the person's profile edit page, ignoring desired path" do
      request.session[:desired_path] = "/search"
      post :create_person, params: person_params
      expect(response).to redirect_to edit_person_path(Person.find_by(email: "fred.bloggs@digital.justice.gov.uk"), page_title: "Create profile")
    end
  end
end
