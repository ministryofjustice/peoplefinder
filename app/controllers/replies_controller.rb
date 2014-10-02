class RepliesController < ApplicationController
  def index
    show_tabs
    @replies = scope.all
  end

private

  def scope
    current_user.replies
  end
end
