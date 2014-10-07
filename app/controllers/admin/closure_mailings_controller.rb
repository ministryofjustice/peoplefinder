module Admin
  class ClosureMailingsController < AdminController
    def create
      ClosureMailingJob.perform_later
      notice :created
      redirect_to admin_path
    end
  end
end
