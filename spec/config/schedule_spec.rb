require 'rails_helper'

RSpec.describe 'Whenever schedule' do
  let(:schedule) { Whenever::Test::Schedule.new(file: 'config/schedule.rb') }

  context 'production environment' do
    before { allow(ENV).to receive(:[]).with('ENV').and_return 'production' }

    it 'has expected number of jobs' do
      expect(schedule.jobs[:rails_script].count).to eql 8
    end

    it 'all rails script runnner job tasks are defined' do
      schedule.jobs[:rails_script].each do |job|
        expect(job[:task]).to be_defined
      end
    end
  end

  context 'non-production enviroments' do
    before { allow(ENV).to receive(:[]).with('ENV').and_return 'staging' }

    it 'does not schedule any jobs' do
      expect(schedule.jobs[:rails_script]).to be_nil
    end
  end
end
