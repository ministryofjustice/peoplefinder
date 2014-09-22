require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to(:recipient) }
  it { should validate_presence_of(:recipient_id) }
  it { should validate_presence_of(:sender_email) }
  it { should validate_presence_of(:message) }
end
