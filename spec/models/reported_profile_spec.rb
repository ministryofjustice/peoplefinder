require 'rails_helper'

RSpec.describe Peoplefinder::ReportedProfile, type: :model do
  it { should belong_to(:notifier) }
  it { should belong_to(:subject) }

  it { should validate_presence_of(:recipient_email) }
  it { should validate_presence_of(:notifier_id) }
  it { should validate_presence_of(:subject_id) }
  it { should validate_presence_of(:reason_for_reporting) }
end
