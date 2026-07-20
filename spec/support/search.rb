module SpecSupport
  module Search
    def clean_up_indexes_and_tables
      Membership.delete_all
      Person.delete_all
      Group.delete_all
      PermittedDomain.delete_all
      PaperTrail::Version.delete_all
    end
  end
end
