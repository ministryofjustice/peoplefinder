require 'spec_helper'
require 'problem_report'

RSpec.describe ProblemReport, type: :model do
  let(:current_time) { Time.at(1_410_298_077) }

  it 'sets timestamp on instantiation' do
    subject = nil

    Timecop.freeze(current_time) do
      subject = described_class.new
    end

    expect(subject.timestamp).to eq(current_time.to_i)
  end

  it 'exposes timestamp as a time' do
    subject = nil

    Timecop.freeze(current_time) do
      subject = described_class.new
    end

    expect(subject.reported_at).to be_kind_of(Time)
    expect(subject.reported_at).to eq(current_time)
  end

  it 'preserves timestamp supplied via initialisation' do
    subject = nil
    previous_time = current_time - 500

    Timecop.freeze(current_time) do
      subject = described_class.new(timestamp: previous_time)
    end

    expect(subject.timestamp).to eq(previous_time.to_i)
  end
end
