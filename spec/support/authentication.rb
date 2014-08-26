module SpecSupport
  module Authentication
    def authenticate_as(user)
      session[:current_user_id] = user
    end
  end
end
