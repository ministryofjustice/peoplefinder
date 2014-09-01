class RepliesController < ApplicationController
  def index
    @replies = scope.all
  end

private

  def scope
    current_user.replies
  end
end
