class AssignmentController < ApplicationController
  before_action AOTokenFilter
 
  def index
    render inline: 'a page goes here'
  end

end