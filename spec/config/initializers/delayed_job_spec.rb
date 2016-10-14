require 'rails_helper'

RSpec.context 'on initialization', type: :initializer do

  it 'sets max attempts to a low number to prevent unnecessary erroring job repetition' do
    expect(Delayed::Worker.max_attempts).to be_between(3, 7)
  end

  it 'sets maximum run time for job to about an hour to help prevent CPU credit limit exceeding' do
    expect(Delayed::Worker.max_run_time).to be_between(30.minutes, 2.hours)
  end
end
