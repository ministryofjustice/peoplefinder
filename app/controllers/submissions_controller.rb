class SubmissionsController < ApplicationController
  def index
    @submissions = current_user.submissions.all
  end
end
