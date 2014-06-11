require 'spec_helper'

describe 'WatchlistReportService' do

  let!(:watchlist_one) { create(:watchlist_member, name: 'member 1', email: 'm1@ao.gov',  deleted: false) }
  let!(:watchlist_two) { create(:watchlist_member, name: 'member 2', email: 'm2@ao.gov', deleted: false) }
  let!(:watchlist_deleted) { create(:watchlist_member, name: 'member 3', email: 'm3@ao.gov', deleted: true) }

  before(:each) do
    @report_service = WatchlistReportService.new
    ActionMailer::Base.deliveries = []
  end

  it 'should have generated a valid token' do

    @report_service.send()

    # first watchlist member
    token = Token.where(entity: "watchlist:#{watchlist_one.id}", path: '/watchlist/dashboard').first
    token.should_not be nil
    token.id.should_not be nil
    token.token_digest.should_not be nil

    end_of_day = DateTime.now.end_of_day.change({:offset => 0})
    token.expire.should eq(end_of_day)


    # second watchlist member
    token = Token.where(entity: "watchlist:#{watchlist_two.id}", path: '/watchlist/dashboard').first
    token.should_not be nil
    token.id.should_not be nil
    token.token_digest.should_not be nil

    end_of_day = DateTime.now.end_of_day.change({:offset => 0})
    token.expire.should eq(end_of_day)


    # the token is not send to deleted Watchlist members
    token = Token.where(entity: "watchlist:#{watchlist_deleted.id}", path: '/watchlist/dashboard').first
    token.should be nil
  end

  it 'should send an email with the right data' do

    result = @report_service.send()

    # first email for the first member
    mail = ActionMailer::Base.deliveries.first
    sentToken = result[watchlist_one.id]
    token_param = {token: sentToken}.to_query
    entity = {entity: "watchlist:#{watchlist_one.id}"}.to_query
    url = '/watchlist/dashboard'

    mail.html_part.body.should include watchlist_one.name
    mail.html_part.body.should include url
    mail.html_part.body.should include token_param
    mail.html_part.body.should include entity


    mail.text_part.body.should include watchlist_one.name
    mail.text_part.body.should include url
    mail.text_part.body.should include token_param
    mail.text_part.body.should include entity

    mail.to.should include watchlist_one.email


    # second email for the second member
    mail = ActionMailer::Base.deliveries[1]
    sentToken = result[watchlist_two.id]
    token_param = {token: sentToken}.to_query
    entity = {entity: "watchlist:#{watchlist_two.id}"}.to_query
    url = '/watchlist/dashboard'

    mail.html_part.body.should include watchlist_two.name
    mail.html_part.body.should include url
    mail.html_part.body.should include token_param
    mail.html_part.body.should include entity


    mail.text_part.body.should include watchlist_two.name
    mail.text_part.body.should include url
    mail.text_part.body.should include token_param
    mail.text_part.body.should include entity

    mail.to.should include watchlist_two.email


  end



end