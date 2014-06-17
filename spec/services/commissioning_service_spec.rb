require 'spec_helper'

describe 'CommissioningService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:pq) { create(:PQ, uin: 'HL789', question: 'test question?') }
  let!(:pending) { create(:progress, name: 'Allocated Pending') }


  before(:each) do
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end

  it 'should return the assignment id and inserts the data' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)

    result.should_not be nil
    result[:assignment_id].should_not be nil

    ActionOfficersPq.where(action_officer_id: action_officer.id, pq_id: pq.id).first.should_not be nil
  end

  it 'should have generated a valid token' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)

    token = Token.where(entity: "assignment:#{result[:assignment_id]}", path: '/assignment/HL789').first

    token.should_not be nil
    token.id.should_not be nil
    token.token_digest.should_not be nil

    tomorrow_midnight = DateTime.now.midnight.change({:offset => 0}) + 1.days
    token.expire.should eq(tomorrow_midnight)

  end

  it 'should send an email with the right data' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)
    sentToken = result[:token]

    mail = ActionMailer::Base.deliveries.first


    token_param = {token: sentToken}.to_query
    entity = {entity: "assignment:#{result[:assignment_id]}"}.to_query
    url = "/assignment/HL789"

    mail.html_part.body.should include pq.question
    mail.html_part.body.should include action_officer.name
    mail.html_part.body.should include url
    mail.html_part.body.should include token_param
    mail.html_part.body.should include entity

    mail.text_part.body.should include pq.question
    mail.text_part.body.should include action_officer.name
    mail.text_part.body.should include url
    mail.text_part.body.should include token_param
    mail.text_part.body.should include entity

    mail.to.should include action_officer.email

  end


  it 'should set the progress to Allocated Pending' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)

    result.should_not be nil

    assignment_id = result[:assignment_id]
    assignment_id.should_not be nil

    assignment = ActionOfficersPq.find(assignment_id)

    pq = PQ.find(assignment.pq_id)
    pq.progress.name.should == 'Allocated Pending'

  end



  it 'should raise an error if the action_officer.id is null' do
    assignment = ActionOfficersPq.new(pq_id: pq.id)
    expect {
      @comm_service.send(assignment)
    }.to raise_error 'Action Officer is not selected'
  end

  it 'should raise an error if the pq_id is null' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id)
    expect {
      @comm_service.send(assignment)
    }.to raise_error 'Question is not selected'
  end


end