require 'rails_helper'

RSpec.describe Submission, type: :model do
  let(:submission) { build(:submission) }

  describe 'status' do
    context 'when the status is set to the default "no_response"' do

      it 'is "started" after update with status=started' do
        submission.status = :started
        submission.save!
        expect(submission.status).to eql(:started)
      end

      it 'is "rejected" after update with status=rejected' do
        submission.status = :rejected
        submission.save!
        expect(submission.status).to eql(:rejected)
      end
    end
  end
end
