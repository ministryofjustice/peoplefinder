class VersionPolicy < ApplicationPolicy
  def index?
    regular_user?
  end

  def undo?
    regular_user?
  end
end
