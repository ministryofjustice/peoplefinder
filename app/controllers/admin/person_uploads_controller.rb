module Admin
  class PersonUploadsController < ApplicationController
    def new
      @upload = PersonUpload.new
    end

    def create
      @upload = PersonUpload.new(filtered_params)
      if @upload.save
        notice :upload_succeeded, count: @upload.import_count
        redirect_to action: :new
      else
        error :upload_failed
        render action: :new
      end
    end

  private

    def filtered_params
      params.require(:person_upload).permit(:group_id, :file)
    end
  end
end
