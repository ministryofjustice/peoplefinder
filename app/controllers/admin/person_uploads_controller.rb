module Admin
  class PersonUploadsController < ApplicationController

    def new
      @upload = PersonUpload.new
      authorize @upload
    end

    def create
      @upload = PersonUpload.new(person_upload_params)
      authorize @upload
      if @upload.save
        notice :upload_succeeded, count: @upload.import_count
        redirect_to action: :new
      else
        render action: :new
      end
    end

    private

    def person_upload_params
      params.require(:person_upload).permit(:group_id, :file)
    end
  end
end
