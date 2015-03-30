namespace :peoplefinder do
  namespace :permitted_domains do
    desc 'Seed default permitted domains'
    task seed: :environment do
      permitted_domains = %w[
        cjs.gsi.gov.uk
        digital.cabinet-office.gov.uk
        digital.justice.gov.uk
        hmcourts-service.gsi.gov.uk
        hmcts.gsi.gov.uk
        hmps.gsi.gov.uk
        homeoffice.gsi.gov.uk
        ips.gsi.gov.uk
        justice.gsi.gov.uk
        legalaid.gsi.gov.uk
        noms.gsi.gov.uk
        publicguardian.gsi.gov.uk
        yjb.gsi.gov.uk
      ]

      permitted_domains.each do |domain|
        Peoplefinder::PermittedDomain.find_or_create_by(domain: domain)
      end
    end
  end
end
