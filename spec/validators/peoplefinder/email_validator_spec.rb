require 'rails_helper'

RSpec.describe Peoplefinder::EmailValidator do
  class TestModel
    include ActiveModel::Model

    attr_accessor :email

    validates :email, 'peoplefinder/email' => true
  end

  before do
    allow(Rails.configuration).to receive(:valid_login_domains).and_return(['valid.gov.uk'])
  end

  subject { TestModel.new(email: email) }

  context 'email is a valid email with a supported domain' do
    let(:email) { 'name.surname@valid.gov.uk' }

    it { is_expected.to be_valid }
  end

  context 'email is a valid e-mail, but with an unsupported domain' do
    let(:email) { 'name@invalid.gov.uk' }

    it { is_expected.not_to be_valid }
  end

  context 'email is not a valid e-mail, but with a supported domain' do
    let(:email) { 'name surname@valid.gov.uk' }

    it { is_expected.not_to be_valid }
  end
end
