module Admin
  class ManagementPolicy < ApplicationPolicy

    def show?
      admin_user?
    end

  end
end
