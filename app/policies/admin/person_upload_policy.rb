module Admin
  class PersonUploadPolicy < ApplicationPolicy

    def new?
      regular_user?
    end

    def create?
      regular_user?
    end

  end
end
