class QuestionsHttpClient

  def initialize(base_url = Settings.pq_rest_api.url, username = Settings.pq_rest_api.username, password = Settings.pq_rest_api.password)
    @base_url = base_url
    @username = username
    @password = password

    @client = HTTPClient.new
    @client.set_auth(@base_url, @username, @password)

  end

  def questions_by_date(date = Date.today)
    endpoint = URI::join(@base_url, '/api/qais/questions')
    response = @client.get(endpoint, "dateFrom" => "2014-04-17") # hardcode the date for testing now
    response.content
  end
end