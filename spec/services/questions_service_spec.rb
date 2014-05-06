require 'spec_helper'

describe 'QuestionsService' do

  it 'questions should return a list of questions with data' do
    xml  = Nokogiri::XML(sample_questions)
    xml.remove_namespaces! # easy to parse if we are only using one namespace
    questions_xml = xml.xpath('//Question')

    questions = Array.new

    questions_xml.each do |q|
      item = Hash.from_xml(q.to_xml)
      questions.push(item["Question"])
    end

    uin = questions[0]["Uin"]
    uin.should eq('HL4837')

    uin = questions[1]["Uin"]
    uin.should eq('HL4838')

    update_date = questions[1]["UpdatedDate"]
    update_date.should eq('2013-02-04T10:30:46.45327Z')

  end
end