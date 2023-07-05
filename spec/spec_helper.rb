require "webmock/rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  WebMock.disable_net_connect!(allow_localhost: true, allow: "chromedriver.storage.googleapis.com")
  WebMock.allow_net_connect!(net_http_connect_on_start: true)

  config.before :each, geckoboard: true do
    stub_request(:get, "https://api.geckoboard.com/")
      .with(headers: { "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "User-Agent" => /Geckoboard-Ruby\/0\.\d+(\.\d)*/ })
      .to_return(status: 200, body: "", headers: {})
  end

  config.before :each, csv_report: true do
    delete_csv_reports
  end

  config.after :all, csv_report: true do
    delete_csv_reports
  end

  def delete_csv_reports
    Dir[Report.new.__send__(:tmp_dir).join("**", "*")].each do |file|
      File.delete(file)
    end
  end
end

# enable csrf testing in feature specs - `with_csrf_protection: true`
RSpec.configure do |config|
  config.around(:each, :with_csrf_protection) do |example|
    orig = ActionController::Base.allow_forgery_protection

    begin
      ActionController::Base.allow_forgery_protection = true
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = orig
    end
  end
end
