class VersionPolicy < ApplicationPolicy
  def index?
    admin_user?
  end

  def undo?
    admin_user?
  end
end
