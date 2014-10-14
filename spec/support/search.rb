module SpecSupport
  module Search
    def clean_up_indexes_and_tables
      Peoplefinder::Person.__elasticsearch__.create_index! index: Peoplefinder::Person.index_name, force: true
      Peoplefinder::Membership.delete_all
      Peoplefinder::Person.delete_all
      Peoplefinder::Group.delete_all
      # => paper trail is behaving inappropriately and versions are still created
      # => PaperTrail.enabled? should be 'false' unless implicitly set.
      # => This appears to be due to the before(:all) blocks needed by the specs
      # => that use elasticsearch.
      PaperTrail::Version.delete_all
    end
  end
end
