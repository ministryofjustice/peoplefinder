class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    regular_user? || third_party_admin_user?
  end

  def update?
    regular_user? || third_party_admin_user?
  end

  def new?
    regular_user? || third_party_admin_user?
  end

  def create?
    regular_user? || third_party_admin_user?
  end

  def destroy?
    regular_user? || third_party_admin_user?
  end
end
