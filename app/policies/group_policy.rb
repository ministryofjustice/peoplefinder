class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    admin_user?
  end

  def update?
    admin_user?
  end

  def new?
    admin_user?
  end

  def create?
    admin_user?
  end

  def destroy?
    admin_user?
  end
end
