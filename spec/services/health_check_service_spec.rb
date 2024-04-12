require "rails_helper"

describe HealthCheckService do
  subject(:health_check_report) { described_class.new }

  before do
    stub_const("HealthCheckReport", Struct.new(:status, :messages))
  end

  it "calls accessible and available on all checks" do
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:available?).and_return(true)
    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:available?).and_return(true)
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:accessible?).and_return(true)
    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:accessible?).and_return(true)

    result = health_check_report.report
    expect(result.status).to eq "200"
    expect(result.messages).to eq "All Components OK"
  end

  it "collects error messages if any checks fail" do
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:available?).and_return(false)
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:accessible?).and_return(false)
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:errors)
      .and_return(["DB Message 1", "DB Message 2"])

    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:available?).and_return(false)
    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:accessible?).and_return(false)
    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:errors)
      .and_return(["ES Message 1", "ES Message 2"])

    result = health_check_report.report
    expect(result.status).to eq "500"
    expect(result.messages).to eq(
      [
        "DB Message 1",
        "DB Message 2",
        "ES Message 1",
        "ES Message 2",
      ],
    )
  end

  it "sends error details to Sentry" do
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:available?).and_return(false)
    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:available?).and_return(true)
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:accessible?).and_return(true)
    allow_any_instance_of(HealthCheck::OpenSearch) # rubocop:disable RSpec/AnyInstance
      .to receive(:accessible?).and_return(true)
    allow_any_instance_of(HealthCheck::Database) # rubocop:disable RSpec/AnyInstance
      .to receive(:errors)
      .and_return(["DB Message 1"])

    expect(Sentry).to receive(:capture_message).with(["DB Message 1"])
    health_check_report.report
  end
end
