require 'rails_helper'

describe StateManagerCookie do

  let(:smc) { described_class.new('state-manager' => 'action=create&phase=edit-picture', 'other-cookie' => 'something') }

  describe '.static_create_and_save' do
    it 'generates a state cookie manager with action create and phase save-profile' do
      smc = described_class.static_create_and_save
      expect(smc.create?).to be true
      expect(smc.save_profile?).to be true
    end
  end

  describe '.new' do
    it 'generates an empty cookie if state-manager cookie is nil' do
      cookie_jar = { 'state-manager' => nil, 'other-cookie' => 'something' }
      smc = described_class.new(cookie_jar)
      expect(state_hash(smc)).to eq({})
    end

    it 'generates the correct keys' do
      expect(state_hash(smc)).to eq('action' => 'create', 'phase' => 'edit-picture')
      expect(smc.create?).to be true
      expect(smc.update?).to be false
      expect(smc.edit_picture?).to be true
    end

    it 'generates an empty cookie if the cookie jar doesnt have an entry for the state manager' do
      cookie_jar = { 'other-cookie' => 'something' }
      smc = described_class.new(cookie_jar)
      expect(state_hash(smc)).to eq({})
    end
  end

  describe '#to_cookie' do
    it 'serialises into a string' do
      expect(smc.to_cookie).to eq 'action=create&phase=edit-picture'
    end
  end

  describe '#cookie_key' do
    it 'returns the key used to store the state cookie' do
      expect(smc.cookie_key).to eq 'state-manager'
    end
  end

  def state_hash(state_manager)
    state_manager.instance_variable_get(:@state_hash)
  end

end
