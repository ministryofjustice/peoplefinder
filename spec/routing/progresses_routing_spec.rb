require "spec_helper"

describe ProgressesController do
  describe "routing" do

    it "routes to #index" do
      get("/progresses").should route_to("progresses#index")
    end

    it "routes to #new" do
      get("/progresses/new").should route_to("progresses#new")
    end

    it "routes to #show" do
      get("/progresses/1").should route_to("progresses#show", :id => "1")
    end

    it "routes to #edit" do
      get("/progresses/1/edit").should route_to("progresses#edit", :id => "1")
    end

    it "routes to #create" do
      post("/progresses").should route_to("progresses#create")
    end

    it "routes to #update" do
      put("/progresses/1").should route_to("progresses#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/progresses/1").should route_to("progresses#destroy", :id => "1")
    end

  end
end
