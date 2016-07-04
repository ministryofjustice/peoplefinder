module Admin
  class PersonUploadsController < ApplicationController
    def new
      @upload = PersonUpload.new
    end

    def create
      @upload = PersonUpload.new(person_upload_params)
      if @upload.save
        notice :upload_succeeded, count: @upload.import_count
        redirect_to action: :new
      else
        error :upload_failed
        render action: :new
      end
    end

    private

    def person_upload_params
      params.require(:person_upload).permit(:group_id, :file)
    end
  end
end
