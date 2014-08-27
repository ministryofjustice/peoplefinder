module SpecSupport
  module Authentication
    def authenticate_as(object)
      if object.is_a?(User)
        session[:current_user_id] = object

      elsif object.is_a?(Review)
        session[:review_id] = object.id
      end
    end
  end
end
