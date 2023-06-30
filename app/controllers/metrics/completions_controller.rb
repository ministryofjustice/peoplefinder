module Metrics
  class CompletionsController < ApplicationController
    skip_before_action :ensure_user

    def index
      render json: {
        "item" => Person.overall_completion,
        "min" => { "value" => 0 },
        "max" => { "value" => 100 },
      }
    end
  end
end
