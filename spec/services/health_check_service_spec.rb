require 'spec_helper'

describe HealthCheckService do

  HealthCheckReport = Struct.new(:status, :messages)

  context 'PqaApi is run' do
    it 'should call accessible and avaiable on all checks' do
      expect(HealthCheck::PqaApi).to receive(:time_to_run?).and_return(true)
      expect_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::SendGrid).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::PqaApi).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(true)
      expect_any_instance_of(HealthCheck::SendGrid).to receive(:accessible?).and_return(true)
      expect_any_instance_of(HealthCheck::PqaApi).to receive(:accessible?).and_return(true)

      result = HealthCheckService.new.report
      expect(result.status).to eq '200'
      expect(result.messages).to eq 'All Components OK'
    end

    it 'should not call accessible and available on PQA API check if not time to run' do
      expect(HealthCheck::PqaApi).to receive(:time_to_run?).and_return(false)
      expect_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::SendGrid).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(true)
      expect_any_instance_of(HealthCheck::SendGrid).to receive(:accessible?).and_return(true)

      expect_any_instance_of(HealthCheck::PqaApi).not_to receive(:available?)
      expect_any_instance_of(HealthCheck::PqaApi).not_to receive(:accessible?)

      result = HealthCheckService.new.report
      expect(result.status).to eq '200'
      expect(result.messages).to eq 'All Components OK'
    end

    it 'should collect error messages if any checks fail' do
      expect(HealthCheck::PqaApi).to receive(:time_to_run?).and_return(true)

      expect_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(false)
      expect_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(false)
      expect_any_instance_of(HealthCheck::Database).to receive(:error_messages).and_return( [ 'DB message 1', 'DB Message 2'] )

      expect_any_instance_of(HealthCheck::SendGrid).to receive(:available?).and_return(false)
      expect_any_instance_of(HealthCheck::SendGrid).to receive(:accessible?).and_return(false)
      expect_any_instance_of(HealthCheck::SendGrid).to receive(:error_messages).and_return( [ 'SG message 1', 'SG Message 2'] )

      expect_any_instance_of(HealthCheck::PqaApi).to receive(:available?).and_return(false)
      expect_any_instance_of(HealthCheck::PqaApi).to receive(:accessible?).and_return(false)
      expect_any_instance_of(HealthCheck::PqaApi).to receive(:error_messages).and_return( [ 'API message 1', 'API Message 2'] )

      result = HealthCheckService.new.report
      expect(result.status).to eq '500'
      expect(result.messages).to eq( ["DB message 1", "DB Message 2", "SG message 1", "SG Message 2", "API message 1", "API Message 2"] )

    end



  end

end






# def initialize
#     @components = []
#     @components << HealthCheck::Database.new
#     @components << HealthCheck::SendGrid.new
#     @components << HealthCheck::PqaApi.new if HealthCheck::PqaApi.time_to_run?
#   end

#   def report
#     @components.all?(&:available?)
#     @components.all?(&:accessible?)

#     errors = @components.map(&:error_messages).flatten

#     if errors.empty?
#       HealthCheckReport.new('200', 'All Components OK')
#     else
#       HealthCheckReport.new('500', errors)
#     end
#   end

#   HealthCheckReport = Struct.new(:status, :messages)
# end