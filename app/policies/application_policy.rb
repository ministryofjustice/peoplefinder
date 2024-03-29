class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

private

  def admin_user?
    @user.is_a?(Person) && @user.super_admin?
  end

  def regular_user?
    @user.is_a?(Person)
  end

  def readonly_user?
    @user.is_a?(ReadonlyUser)
  end
end
