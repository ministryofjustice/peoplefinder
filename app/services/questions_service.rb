class QuestionsService

  # now is just a mock service
  def initialize(sample_file = File.open(Rails.root.join('config/fixtures/questions.xml')))
    @mock_response = sample_file
  end


  def questions_by_date(date = Date.today)
    xml  = Nokogiri::XML(@mock_response)
    xml.remove_namespaces! # easy to parse if we are only using one namespace
    questions_xml = xml.xpath('//Question')

    questions = Array.new

    questions_xml.each do |q|
      item = Hash.from_xml(q.to_xml)
      questions.push(item["Question"])
    end

    questions

  end

end