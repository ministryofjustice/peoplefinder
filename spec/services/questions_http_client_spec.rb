require 'spec_helper'

describe 'QuestionsHttpClient' do

  before(:each) do
    @http_client = QuestionsHttpClient.new
  end

  # Mark as a pending because it need the credentials for the API to pass
  xit 'should get an xml response from the PQ API' do
    questions_xml = @http_client.questions("dateFrom" => "2014-04-17")
    questions_xml.should include("<Questions")
  end

end