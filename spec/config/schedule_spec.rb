require 'rails_helper'

RSpec.describe 'Whenever schedule' do
  let(:schedule) { Whenever::Test::Schedule.new(file: 'config/schedule.rb') }

  it 'has 7 jobs' do
    expect(schedule.jobs[:rails_script].count).to eql 7
  end

  it 'all rails script runnner job tasks are defined' do
    schedule.jobs[:rails_script].each do |job|
      expect(job[:task]).to be_defined
    end
  end
end
