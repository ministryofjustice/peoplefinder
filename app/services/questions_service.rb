class QuestionsService

  def initialize(http_client = QuestionsHttpClient.new)
    @http_client = http_client
  end

  # valid args
  # :dateFrom  YYYY-MM-DDTHH:mm:ss
  # :dateTo    YYYY-MM-DDTHH:mm:ss
  # :status
  #         "Tabled",
  #         "Withdrawn"
  #         "WithdrawnWithoutNotice"
  #         "AnswerNotExpected"
  #         "Incomplete"
  #         "PendingCorrectionReview"
  #         "PendingAnswerReview"
  #         "ReturnedVirus"
  #         "ReturnedCorrection"
  #         "ReturnedAnswer"
  #         "Answered"
  #         "Holding"
  #         "ScanningForVirus"
  def questions(args = { dateFrom: Date.today} )
    format = "%Y-%m-%dT%H:%M:%S"
    options = {}
    options["dateFrom"] = args[:dateFrom].strftime(format)
    options["dateTo"] = args[:dateTo].strftime(format) if args[:dateTo].present?
    options["status"] = args[:status] if args[:status].present?

    response = @http_client.questions(options)

    return parse_questions_xml(response)
  end

  def questions_by_uin(uin)
    response = @http_client.question(uin)
    questions = parse_questions_xml(response)
    questions.first
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