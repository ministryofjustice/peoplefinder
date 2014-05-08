class QuestionsService

  def initialize(http_client = QuestionsMockHttpClient.new)
    @http_client = http_client
  end


  def questions_by_date(date = Date.today)
    response = @http_client.questions_by_date(date)
    xml  = Nokogiri::XML(response)
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