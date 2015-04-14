module PermittedDomainHelper
  extend ActiveSupport::Concern

  included do
    before do
      PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk')
    end
  end
end
