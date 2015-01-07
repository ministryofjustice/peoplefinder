require 'rails_helper'

RSpec.describe Invitation, type: :model do
  subject { described_class.new(create(:review)) }
  let(:reason) { "I don't know you" }

  it 'sends appropriate messaging should an subject be declined' do
    mail = double
    expect(ReviewMailer).to receive(:request_declined) { mail }
    expect(mail).to receive(:deliver)
    subject.update status: :declined, reason_declined: reason
  end

  it 'returns falsey when updating with an invalid state' do
    expect(
      subject.update(status: 'lets_go_for_a_swim', reason_declined: reason)
    ).to be_falsey
  end

  it 'returns truthy when declining with a reason' do
    expect(
      subject.update(status: 'declined', reason_declined: reason)
    ).to be_truthy
  end

  it 'returns falsey when declining without a reason' do
    expect(
      subject.update(status: 'declined', reason_declined: '')
    ).to be_falsey
  end

  it 'returns truthy when accepting without a reason' do
    expect(
      subject.update(status: 'accepted', reason_declined: '')
    ).to be_truthy
  end

  it 'mandates a reason if the subject is declined' do
    subject.update status: 'declined', reason_declined: ''
    expect(subject.errors[:reason_declined]).
      to include('If declining, please include a reason')
  end
end
