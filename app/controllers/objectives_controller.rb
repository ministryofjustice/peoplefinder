class ObjectivesController < ApplicationController

  def index
    @objectives = scope.objectives
  end

  private

  def scope
    Agreement.
        editable_by(current_user).
        find(params[:agreement_id])
  end

end
