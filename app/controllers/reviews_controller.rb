class ReviewsController < ParticipantsController
  before_action :load_explicit_subject, only: [:index, :create, :show]
  before_action :redirect_unless_user_receives_feedback, only: [:index]
  skip_before_action :ensure_participant, only: [:show]

  def index
    @review = scope.new
    load_reviews
  end

  def create
    @review = scope.new(review_params)

    if @review.save
      FeedbackRequest.new(@review).send
      notice :created, name: @review.author_name
      redirect_to action: :index
    else
      error :create_error
      load_reviews
      render action: :index
    end
  end

  def show
    @review = Review.submitted.
      for_user(@subject || current_user).find(params[:id])
  end

private

  def review_params
    params.require(:review).
      permit(:author_email, :author_name, :relationship, :invitation_message)
  end

  def scope
    (@subject || current_user).reviews
  end

  def load_explicit_subject
    if params[:user_id]
      @subject = current_user.managees.find(params[:user_id])
    end
    true
  end

  def redirect_unless_user_receives_feedback
    redirect_to users_path unless (@subject || current_user).manager
  end

  def load_reviews
    @reviews = scope.all
  end
end
