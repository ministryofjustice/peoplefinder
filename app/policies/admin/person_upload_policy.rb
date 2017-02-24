module Admin
  class PersonUploadPolicy < ApplicationPolicy

    def new?
      admin_user?
    end

    def create?
      admin_user?
    end

  end
end
