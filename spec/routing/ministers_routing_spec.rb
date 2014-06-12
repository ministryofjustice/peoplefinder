require "spec_helper"

describe MinistersController do
  describe "routing" do

    it "routes to #index" do
      get("/ministers").should route_to("ministers#index")
    end

    it "routes to #new" do
      get("/ministers/new").should route_to("ministers#new")
    end

    it "routes to #show" do
      get("/ministers/1").should route_to("ministers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ministers/1/edit").should route_to("ministers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ministers").should route_to("ministers#create")
    end

    it "routes to #update" do
      put("/ministers/1").should route_to("ministers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ministers/1").should route_to("ministers#destroy", :id => "1")
    end

  end
end
