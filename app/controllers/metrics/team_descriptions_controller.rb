module Metrics
  class TeamDescriptionsController < ApplicationController
    skip_before_action :ensure_user

    def index
      render json: {
        'item' => Group.percentage_with_description,
        'min' => { 'value' => 0 },
        'max' => { 'value' => 100 }
      }
    end
  end
end
