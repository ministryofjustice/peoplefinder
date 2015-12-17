every :weekday, at: '8am' do
  runner 'NeverLoggedInNotifier.send_reminders'
end
