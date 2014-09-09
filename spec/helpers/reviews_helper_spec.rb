require 'rails_helper'
include ReviewsHelper

describe ReviewsHelper do

  let(:current_user) { build(:user) }
  let(:subject) { build(:user) }

  context 'role_translate' do
    it "uses 'theirs' as the subkey for a manager" do
      @subject = subject
      expect(I18n).to receive(:t).with('foo.theirs', anything)
      role_translate('foo')
    end

    it "uses 'mine' as the subkey for a direct report" do
      @subject = nil
      expect(I18n).to receive(:t).with('foo.mine', anything)
      role_translate('foo')
    end

    it "uses the manager's direct report for the name" do
      @subject = subject
      expect(I18n).to receive(:t).with(anything, name: subject)
      role_translate('foo')
    end

    it "uses the current user for the name" do
      @subject = nil
      expect(I18n).to receive(:t).with(anything, name: current_user)
      role_translate('foo')
    end

    it 'returns the translation' do
      allow(I18n).to receive(:t) { 'TRANSLATED' }
      expect(role_translate('foo')).to eql('TRANSLATED')
    end
  end
end
