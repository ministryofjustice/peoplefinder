module Metrics
  class ActivationsController < ApplicationController
    skip_before_action :ensure_user

    def index
      date = params[:cohort_split_date]
      date = Date.parse(date).to_s

      bullet_graph = {
        orientation: "horizontal",
        item: [
          aquisition_bullet_graph(date),
          activation_bullet_graph(date)
        ]
      }

      render json: bullet_graph.to_json
    end

    private

    def aquisition_bullet_graph date
      acquired_percentage = Person.acquired_percentage(from: date)

      bullet_graph label: "#{acquired_percentage}% logged in at least once",
        sublabel: "users created from #{date}",
        current_end: acquired_percentage,
        comparative_point: Person.acquired_percentage(before: date)
    end

    def activation_bullet_graph date
      activated_percentage = Person.activated_percentage(from: date)

      bullet_graph label: "#{activated_percentage}% of acquired users completed > 80%",
        sublabel: "users created from #{date}",
        current_end: activated_percentage,
        comparative_point: Person.activated_percentage(before: date)
    end

    def bullet_graph label:, sublabel:, current_end:, comparative_point:
      {
        label: label,
        sublabel: sublabel,
        axis: {
          point: [0, 20, 40, 60, 80, 100]
        },
        range: {
          red:   { start:  0, end:  20 },
          amber: { start: 21, end:  80 },
          green: { start: 81, end: 100 }
        },
        measure: {
          current:   { start: 0, end: current_end },
          projected: { start: 0, end: 0 }
        },
        comparative: { point: comparative_point }
      }
    end
  end
end
