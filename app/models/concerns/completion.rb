module Completion
  extend ActiveSupport::Concern

  included do
    COMPLETION_SCORE_FIELDS = [
      :given_name,
      :surname,
      :email,
      :primary_phone_number,
      :secondary_phone_number,
      :location,
      :description,
      :groups
    ]

    def completion_score
      completed = COMPLETION_SCORE_FIELDS.map { |f| send(f).present? }
      (100 * completed.select { |f| f }.length) / COMPLETION_SCORE_FIELDS.length
    end

    def incomplete?
      completion_score < 100
    end
  end
end
