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

      it 'is "declined" after update with status=declined' do
        submission.status = :declined
        submission.save!
        expect(submission.status).to eql(:declined)
      end
    end
  end

  describe 'validity' do
    it 'is valid if all fields are filled' do
      expect(submission).to be_valid
    end

    it 'is valid if fields are empty and status is not submitted' do
      submission.rating_2 = nil
      submission.status = :started
      expect(submission).to be_valid
    end

    it 'is invalid if fields are empty and status is submitted' do
      submission.rating_2 = nil
      submission.status = :submitted
      expect(submission).not_to be_valid
    end
  end
end
