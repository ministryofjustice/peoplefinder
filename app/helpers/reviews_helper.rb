module ReviewsHelper
  def role_translate(key, options = {})
    subkey = @subject ? 'theirs' : 'mine'
    user = @subject || current_user
    I18n.t([key, subkey].join('.'), options.merge(name: user))
  end
end
