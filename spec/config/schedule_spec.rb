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

    it 'all rails runner script jobs command' do
      schedule.jobs[:rails_script].each do |job|
        expect(job[:command]).to eql "cd /usr/src/app && ./rails_runner.sh ':task' :output"
      end
    end
  end

  %w(dev demo staging).each do |env|
    context "#{env} environment" do
      before { allow(ENV).to receive(:[]).with('ENV').and_return env.to_s }
      it 'only schedules the Sender Notification job, every 5 minutes' do
        expect(schedule.jobs[:rails_script].count).to eql 1
        expect(schedule.jobs[:rails_script].first[:task]).to eql "NotificationSender.new.send!"
        expect(schedule.jobs[:rails_script].first[:every]).to include 300.seconds
      end
    end
  end

end
