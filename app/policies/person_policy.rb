class PersonPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    regular_user? || third_party_admin_user?
  end

  def update?
    regular_user? || third_party_admin_user?
  end

  def update_email?
    true
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

  def add_membership?
    regular_user? || third_party_admin_user?
  end
end
