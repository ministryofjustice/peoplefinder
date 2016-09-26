require 'rspec/expectations'

module DelayedJobHelper

  RSpec::Matchers.define :delay_method do |expected|
    def supports_block_expectations?
      true
    end

    match do |proc|
      Delayed::Worker.new.work_off
      proc.call
      job = Delayed::Job.last
      @actual = job.payload_object.method_name.to_sym
      (@actual == expected) || (@actual == "#{expected}_without_delay".to_sym)
    end

    failure_message do |actual|
      "expected code block to have delayed the method '#{expected}' but got '#{@actual}'"
    end

    failure_message_when_negated do |actual|
      "expected code block not to have delayed the method '#{expected}'"
    end
  end

  RSpec::Matchers.define :have_delayed_job do |count|
    def supports_block_expectations?
      true
    end

    match do |proc|
      Delayed::Worker.new.work_off
      @expected_count = count || 1
      ap @expected_count
      before_count = Delayed::Job.count
      proc.call
      after_count = Delayed::Job.count
      @actual_count = (after_count - before_count)
      @actual_count == @expected_count
    end

    failure_message do |process|
      "expected to have enqueued #{@expected_count} delayed job(s) but enqueued #{@actual_count}"
    end

    failure_message_when_negated do |proc|
      "expected not to have enqueued #{@expected_count} delayed job(s) but enqueued #{@actual_count}"
    end
  end

end