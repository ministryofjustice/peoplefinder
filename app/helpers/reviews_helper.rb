module ReviewsHelper
  def review_completion(user)
    I18n.t(
      'completion',
      scope: 'helpers.reviews',
      submitted: user.reviews.submitted.count,
      total: user.reviews.count
    )
  end

  def role_translate(key, options = {})
    subkey = @subject ? 'theirs' : 'mine'
    user = @subject || current_user
    I18n.t([key, subkey].join('.'), options.merge(name: user))
  end
end
