require 'rails_helper'

describe HealthCheckService do
  HealthCheckReport = Struct.new(:status, :messages)

  subject { described_class.new }

  it 'calls accessible and available on all checks' do
    expect_any_instance_of(HealthCheck::Database).
      to receive(:available?).and_return(true)
    expect_any_instance_of(HealthCheck::SendGrid).
      to receive(:available?).and_return(true)
    expect_any_instance_of(HealthCheck::Elasticsearch).
      to receive(:available?).and_return(true)
    expect_any_instance_of(HealthCheck::Database).
      to receive(:accessible?).and_return(true)
    expect_any_instance_of(HealthCheck::SendGrid).
      to receive(:accessible?).and_return(true)
    expect_any_instance_of(HealthCheck::Elasticsearch).
      to receive(:accessible?).and_return(true)

    result = subject.report
    expect(result.status).to eq '200'
    expect(result.messages).to eq 'All Components OK'
  end

  it 'collects error messages if any checks fail' do
    expect_any_instance_of(HealthCheck::Database).
      to receive(:available?).and_return(false)
    expect_any_instance_of(HealthCheck::Database).
      to receive(:accessible?).and_return(false)
    expect_any_instance_of(HealthCheck::Database).
      to receive(:errors).
      and_return(['DB Message 1', 'DB Message 2'])

    expect_any_instance_of(HealthCheck::SendGrid).
      to receive(:available?).and_return(false)
    expect_any_instance_of(HealthCheck::SendGrid).
      to receive(:accessible?).and_return(false)
    expect_any_instance_of(HealthCheck::SendGrid).
      to receive(:errors).
      and_return(['SG Message 1', 'SG Message 2'])

    expect_any_instance_of(HealthCheck::Elasticsearch).
      to receive(:available?).and_return(false)
    expect_any_instance_of(HealthCheck::Elasticsearch).
      to receive(:accessible?).and_return(false)
    expect_any_instance_of(HealthCheck::Elasticsearch).
      to receive(:errors).
      and_return(['ES Message 1', 'ES Message 2'])

    result = subject.report
    expect(result.status).to eq '500'
    expect(result.messages).to eq(
      [
        'DB Message 1',
        'DB Message 2',
        'SG Message 1',
        'SG Message 2',
        'ES Message 1',
        'ES Message 2'
      ]
    )
  end
end
