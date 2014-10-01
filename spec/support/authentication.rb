module SpecSupport
  module Authentication
    def authenticate_as(user)
      session[:user_id] = user.id
    end

    def access_is_denied
      expect(page).to have_text('not authorised')
    end
  end
end
