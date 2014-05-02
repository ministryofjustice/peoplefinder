require 'spec_helper'

describe 'QuestionsService' do

  it 'questions should return a list of questions with data' do
    xml  = Nokogiri::XML(sample_questions)
    xml.remove_namespaces! # easy to parse if we are only using one namespace
    questions = xml.xpath('//Question')

    uid = questions[0].xpath("Uin").first.content
    uid.should eq('HL4837')

  end
end