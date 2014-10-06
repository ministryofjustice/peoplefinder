module SpecSupport
  module ReviewPeriod
    RSpec.configure do |config|
      config.around :each, closed_review_period: true do |example|
        Setting[:review_period] = 'closed'
        example.run
        Setting[:review_period] = 'open'
      end
    end
  end
end
