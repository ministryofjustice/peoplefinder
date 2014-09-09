module ReviewsHelper
  def review_completion(user)
    "#{ user.reviews.submitted.count }\
    of #{ user.reviews.count } completed"
  end
end
