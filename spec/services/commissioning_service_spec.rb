require 'spec_helper'

describe 'CommissioningService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email:'ao@ao.gov') }
  let(:pq) {create(:PQ, uin: 'HL789', question: 'test question?')}


  before(:each) do
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end

  it 'should return a boolean value indicating success/failure and inserts the data' do  	
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
    
    result = @comm_service.send(assignment)

    result.should_not be nil
    ActionOfficersPq.all.count.should eq(1)
  end

  it 'should have generated a valid token' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
    
    @comm_service.send(assignment)

 	token = Token.where(entity: 'ao@ao.gov', path: '/assignment/HL789').first
 	
 	token.id.should_not be nil
 	token.token_digest.should_not be nil

	tomorrow_midnight = DateTime.now.midnight.change({:offset => 0}) + 1.days
 	token.expire.should eq(tomorrow_midnight)

  end

  it 'should send an email with the right data' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
    
    sentToken = @comm_service.send(assignment)

 	mail = ActionMailer::Base.deliveries.first


	token_param = {token: sentToken}.to_query
	entity = {entity: action_officer.email }.to_query
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

end