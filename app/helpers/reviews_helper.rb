module ReviewsHelper
  def third_party?
    @subject && @subject != current_user
  end

  def role_translate(key, options = {})
    if third_party?
      subkey = 'theirs'
      user = @subject
    else
      subkey = 'mine'
      user = current_user
    end
    I18n.t([key, subkey].join('.'), options.merge(name: user))
  end
end
