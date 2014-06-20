class AuditsController < ApplicationController
  def index
    @versions = PaperTrail::Version.order(created_at: :desc).limit(1000)
  end
end