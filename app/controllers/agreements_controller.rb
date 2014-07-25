class AgreementsController < ApplicationController
  def index
    @agreements = Agreement.editable_by(current_user)
  end
end
