class HomeController < ApplicationController
  def index
    path = best_path_for_user(current_user)
    redirect_to path if path
  end

private

  def best_path_for_user(user)
    return nil unless user
    return admin_path if user.administrator?
    return reviews_path if user.managed?
    return users_path if user.manages?
    return replies_path if user.reviewer?
    nil
  end
end
