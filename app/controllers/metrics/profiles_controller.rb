module Metrics
  class ProfilesController < ApplicationController
    skip_before_action :ensure_user

    def index
      render json: {
        'item' => [
          {
            'value' => Person.count
          }
        ]
      }
    end
  end
end
