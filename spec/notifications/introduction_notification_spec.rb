require 'rails_helper'

RSpec.describe IntroductionNotification do
  it 'creates a token and emails it to the user' do
    user = create(:user)
    token = double(:token)
    mail = double(:mail)

    expect(user.tokens).to receive(:create!).and_return(token)
    expect(UserMailer).to receive(:introduction).with(user, token).
      and_return(mail)
    expect(mail).to receive(:deliver)

    described_class.new(user).send
  end
end
