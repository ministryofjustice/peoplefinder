require 'spec_helper'

describe 'AssignmentService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:pq) { create(:PQ, uin: 'HL789', question: 'test question?') }


  before(:each) do
    @assignment_service = AssignmentService.new
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end


  describe '#accept' do
    it 'should set the right flags in the assignment' do

      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      assignment.accept.should eq(true)
      assignment.reject.should eq(false)

    end
  end


  describe '#reject' do
    it 'should set the right flags in the assignment' do

      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      assignment = ActionOfficersPq.find(assignment_id)

      assignment.accept.should eq(false)
      assignment.reject.should eq(true)

      assignment.reason.should eq('Some reason')
      assignment.reason_option.should eq('reason option')

    end
  end

end