class AgreementsController < ApplicationController
  def new
    @agreement = Agreement.new
    set_implicit_parameter
  end

private
  def set_implicit_parameter
    @agreement.jobholder = current_user
  end
end
