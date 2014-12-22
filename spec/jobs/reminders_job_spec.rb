require 'rails_helper'

RSpec.describe RemindersJob do
  it 'sends feedback-not-given reminders when 7 ≤ days left < 8' do
    recipient = create(:recipient)
    review = create(:no_response_review, subject: recipient)
    notification = instance_double(FeedbackNotGivenNotification)

    expect(FeedbackNotGivenNotification).to receive(:new).with(review).
      and_return(notification)
    expect(notification).to receive(:notify)

    ReviewPeriod.closes_at = 7.5.days.from_now
    described_class.perform_later
  end

  it 'sends feedback-not-received reminders when 8 ≤ days left < 9' do
    recipient = create(:recipient)
    create(:no_response_review, subject: recipient)
    notification = instance_double(FeedbackNotReceivedNotification)

    expect(FeedbackNotReceivedNotification).to receive(:new).with(recipient).
      and_return(notification)
    expect(notification).to receive(:notify)

    ReviewPeriod.closes_at = 8.5.days.from_now
    described_class.perform_later
  end

  it 'sends closing-soon reminders when 9 ≤ days left < 10' do
    recipient = create(:recipient)
    notification = instance_double(ClosingSoonNotification)

    expect(ClosingSoonNotification).to receive(:new).with(recipient).
      and_return(notification)
    expect(notification).to receive(:notify)

    ReviewPeriod.closes_at = 9.5.days.from_now
    described_class.perform_later
  end

  it 'sends no reminders when there are a different number of days left' do
    recipient = create(:recipient)
    create(:no_response_review, subject: recipient)

    expect(FeedbackNotGivenNotification).not_to receive(:new)
    expect(FeedbackNotReceivedNotification).not_to receive(:new)
    expect(ClosingSoonNotification).not_to receive(:new)

    ReviewPeriod.closes_at = 6.5.days.from_now
    described_class.perform_later
  end

  it 'emails people with feedback to give only once' do
    review = create(:no_response_review)
    create(:no_response_review, author_email: review.author_email)
    notification = instance_double(FeedbackNotGivenNotification)

    expect(FeedbackNotGivenNotification).to receive(:new).once.
      and_return(notification)
    allow(notification).to receive(:notify)

    ReviewPeriod.closes_at =
      (described_class::FEEDBACK_TO_GIVE_DAYS + 0.5).days.from_now
    described_class.perform_later
  end

  it 'emails people with feedback to receive only once' do
    recipient = create(:recipient)
    2.times do
      create(:no_response_review, subject: recipient)
    end
    notification = instance_double(FeedbackNotReceivedNotification)

    expect(FeedbackNotReceivedNotification).to receive(:new).once.
      and_return(notification)
    allow(notification).to receive(:notify)

    ReviewPeriod.closes_at =
      (described_class::FEEDBACK_TO_RECEIVE_DAYS + 0.5).days.from_now
    described_class.perform_later
  end

  it 'does not email users who do not receive feedback' do
    participant_without_manager = create(:user)
    participant_with_manager = create(:user, manager: participant_without_manager)
    non_participant = create(:review, subject: participant_with_manager).author

    notification = instance_double(ClosingSoonNotification)

    expect(ClosingSoonNotification).to receive(:new).
      with(participant_with_manager).once.and_return(notification)
    allow(notification).to receive(:notify)
    expect(ClosingSoonNotification).not_to receive(:new).
      with(participant_without_manager)
    expect(ClosingSoonNotification).not_to receive(:new).
      with(non_participant)

    ReviewPeriod.closes_at =
      (described_class::CLOSING_SOON_DAYS + 0.5).days.from_now
    described_class.perform_later
  end
end
