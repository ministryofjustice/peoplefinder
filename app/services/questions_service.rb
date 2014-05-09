class QuestionsService

  def initialize(http_client = QuestionsHttpClient.new)
    @http_client = http_client
  end

  def questions_by_date(dateFrom = Date.today)
    dateFrom = Date.parse(dateFrom) if dateFrom.is_a? String
    response = @http_client.questions("dateFrom" => dateFrom.strftime("%Y-%m-%d"))
    return parse_questions_xml(response)
  end

  protected

  def parse_questions_xml(response)
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