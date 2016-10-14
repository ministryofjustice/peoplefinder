module ActiveJobHelper
  extend ActiveSupport::Concern
  include ActiveJob::TestHelper

  included do
    around do |example|
      clear_enqueued_jobs
      clear_performed_jobs

      perform_enqueued_jobs do
        example.run
      end
    end
  end

end
