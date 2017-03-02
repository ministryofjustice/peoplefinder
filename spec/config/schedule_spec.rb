require 'rails_helper'

RSpec.describe 'Whenever schedule' do
  let(:schedule) { Whenever::Test::Schedule.new(file: 'config/schedule.rb') }

  context 'production environment' do
    before { allow(ENV).to receive(:[]).with('ENV').and_return 'production' }

    it 'has expected number of jobs' do
      expect(schedule.jobs[:rails_script].count).to eql 10
    end

    it 'all rails script runnner job tasks are defined' do
      schedule.jobs[:rails_script].each do |job|
        expect(job[:task]).to be_defined
      end
    end
  end

  context 'non-production enviroments' do
    context 'staging' do

      before { allow(ENV).to receive(:[]).with('ENV').and_return 'staging' }

      it 'only schedules the Sender Notification job' do
        expect(schedule.jobs[:rails_script]).to eq(
          [
            {
              task: "NotificationSender.new.send!",
              every: [300.seconds],
              command: "cd /usr/src/app && ./rails_runner.sh ':task' :output"
            }
        ])
      end
    end
  end
end
