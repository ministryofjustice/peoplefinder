class QuestionsHttpClient

  def initialize(base_url = Settings.pq_rest_api.url, username = Settings.pq_rest_api.username, password = Settings.pq_rest_api.password)
    @base_url = base_url
    @username = username
    @password = password

    @client = HTTPClient.new
    @client.set_auth(@base_url, @username, @password)

  end

  def questions(options = {})
    endpoint = URI::join(@base_url, '/api/qais/questions')
    response = @client.get(endpoint, options)
    response.content
  end
end