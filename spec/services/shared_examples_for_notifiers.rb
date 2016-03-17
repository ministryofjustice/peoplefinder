shared_examples 'sends reminder email' do |mailer_method|
  context 'when config.send_reminder_emails true' do
    it 'sends email to person' do
      allow(Rails.configuration).to receive(:send_reminder_emails).and_return true
      mail = double
      expect(ReminderMailer).to receive(mailer_method).with(*mailer_params).and_return mail
      expect(mail).to receive(:deliver_later)
      subject.send_reminders
    end
  end

  context 'when config.send_reminder_emails false' do
    it 'does not send email to person' do
      allow(Rails.configuration).to receive(:send_reminder_emails).and_return false
      expect(ReminderMailer).not_to receive(mailer_method)
      subject.send_reminders
    end
  end
end
