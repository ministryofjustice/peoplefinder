module Admin
  class IntroductoryMailingsController < AdminController
    def create
      IntroductoryMailingJob.perform_later
      notice :created
      redirect_to admin_path
    end
  end
end
