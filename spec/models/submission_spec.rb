require 'rails_helper'

RSpec.describe Submission, type: :model do
  let(:submission) { build(:submission) }

  describe 'status' do
    it 'is "submitted" after update with submitted=true' do
      submission.submitted = true
      submission.save!
      expect(submission.status).to eql('submitted')
    end

    it 'is "started" after update with submitted=false' do
      submission.submitted = false
      submission.save!
      expect(submission.status).to eql('started')
    end
  end
end
