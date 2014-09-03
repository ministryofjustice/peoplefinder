module SpecSupport
  module ReviewPeriod
    RSpec.configure do |config|
      config.around :each, closed_review_period: true do |example|
        ENV['REVIEW_PERIOD'] = 'CLOSED'
        example.run
        ENV['REVIEW_PERIOD'] = nil
      end
    end
  end
end
