# This class holds the state during the people creation / edit actions
# and can be serialised to store in a cookie.
#
class StateManagerCookie

  KEY = 'state-manager'.freeze

  # takes a the controller's cookie jar, and extracts what it needs from there
  def initialize(cookie_jar)
    @state_hash = {}
    state_string = cookie_jar[KEY]
    parse(state_string) unless state_string.nil?
  end

  def self.static_create_and_save
    new(KEY => 'action=create&phase=save-profile')
  end

  # SETTERS
  def action_create!
    @state_hash['action'] = 'create'
    self
  end

  def action_update!
    @state_hash['action'] = 'update'
    self
  end

  def phase_edit_picture!
    @state_hash['phase'] = 'edit-picture'
    self
  end

  def phase_save_profile!
    @state_hash['phase'] = 'save-profile'
    self
  end

  def phase_edit_picture_complete!
    @state_hash['phase'] = 'edit-picture-complete'
    self
  end

  # GETTERS
  def create?
    @state_hash['action'] == 'create'
  end

  def update?
    @state_hash['action'] == 'update'
  end

  def edit_picture?
    @state_hash['phase'] == 'edit-picture'
  end

  def edit_picture_complete?
    @state_hash['phase'] == 'edit-picture-complete'
  end

  def save_profile?
    @state_hash['phase'] == 'save-profile'
  end

  # MISCELLANEOUS
  def to_cookie
    @state_hash.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def cookie_key
    KEY
  end

  private

  # takes a string like 'action=create&phase=edit-picture'
  def parse(state_string)
    kv_pairs = state_string.split('&')
    kv_pairs.each do |pair|
      key, val = pair.split('=')
      @state_hash[key] = val
    end
  end
end
