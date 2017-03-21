# TODO: This helper should automatically be included to all specs and therefore we can avoid
#       having the extra line in all specs
module PermittedDomainHelper
  extend ActiveSupport::Concern

  included do
    before do
      PermittedDomain.find_or_create_by(domain: 'digital.justice.gov.uk')
      PermittedDomain.find_or_create_by(domain: 'justice.gov.uk')
    end
  end
end
