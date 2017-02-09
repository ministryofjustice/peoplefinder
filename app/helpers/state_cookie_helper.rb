# the state cookie is in fact a pair of cookies: state_manager_action and state_manager_destination
#
module StateCookieHelper

  def delete_state_cookie
    cookies.delete StateManagerCookie::KEY
  end

  def set_state_cookie_action_create
    smc = StateManagerCookie.new(cookies).action_create!
    cookies[smc.cookie_key] = smc.to_cookie
  end

  def set_state_cookie_action_update
    smc = StateManagerCookie.new(cookies).action_update!
    cookies[smc.cookie_key] = smc.to_cookie
  end

  def set_state_cookie_phase_from_button
    smc = StateManagerCookie.new(cookies)
    if params['edit-picture-button'].present?
      smc.phase_edit_picture!
    elsif params['commit'].present?
      smc.phase_save_profile!
    end
    cookies[smc.cookie_key] = smc.to_cookie
  end

  def set_state_cookie_picture_editing_complete
    smc = StateManagerCookie.new(cookies)
    smc.phase_edit_picture_complete!
    cookies[smc.cookie_key] = smc.to_cookie
  end

  def set_state_cookie_action_update_if_not_create
    smc = StateManagerCookie.new(cookies)
    unless smc.create?
      smc.action_update!
      cookies[smc.cookie_key] = smc.to_cookie
    end
  end

  def state_cookie_editing_picture?
    StateManagerCookie.new(cookies).edit_picture?
  end

  def state_cookie_editing_picture_done?
    StateManagerCookie.new(cookies).edit_picture_complete?
  end

  def state_cookie_saving_profile?
    StateManagerCookie.new(cookies).save_profile?
  end
end
