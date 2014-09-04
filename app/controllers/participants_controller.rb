class ParticipantsController < ApplicationController
  before_action :ensure_participant

private

  def ensure_participant
    forbidden unless current_user.participant
  end
end
