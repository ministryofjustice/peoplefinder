require "spec_helper"

describe ActionOfficersController do
  describe "routing" do

    it "routes to #index" do
      get("/action_officers").should route_to("action_officers#index")
    end

    it "routes to #new" do
      get("/action_officers/new").should route_to("action_officers#new")
    end

    it "routes to #show" do
      get("/action_officers/1").should route_to("action_officers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/action_officers/1/edit").should route_to("action_officers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/action_officers").should route_to("action_officers#create")
    end

    it "routes to #update" do
      put("/action_officers/1").should route_to("action_officers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/action_officers/1").should route_to("action_officers#destroy", :id => "1")
    end

  end
end
