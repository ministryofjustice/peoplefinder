module ReviewsHelper
  def role_translate(key, options = {})
    if @subject && @subject != current_user
      subkey = 'theirs'
      user = @subject
    else
      subkey = 'mine'
      user = current_user
    end
    I18n.t([key, subkey].join('.'), options.merge(name: user))
  end
end
